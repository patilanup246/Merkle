"""
5 Day Forecast
api.openweathermap.org/data/2.5/forecast?q={city name},{country code}

Keys for the dictionaries in 'list'
dict_keys(['rain', 'main', 'dt_txt', 'sys', 'weather', 'dt', 'clouds', 'wind'])

Required output file

'location_id', 'date', 'weather_code', 'max_temp', 'min_temp'

Convert Kelvin to Celsius by subtracting 273.15

EXAMPLE DATA FOR LIST
dct = {'dt': 1476878400,
       'sys': {'pod': 'd'},
       'rain': {},
       'main': {'temp': 288.18, 'humidity': 84, 'temp_min': 286.35, 'temp_kf': 1.83, 'pressure': 1024.73, 'temp_max': 288.18, 'grnd_level': 1024.73, 'sea_level': 1038.28},
       'weather': [{'id': 800, 'main': 'Clear', 'description': 'clear sky', 'icon': '01d'}],
       'wind': {'speed': 5.21, 'deg': 317.504},
       'clouds': {'all': 0},
       'dt_txt': '2016-10-19 12:00:00'}

Overall Process

Run a script on the Spectrum box at midnight
    Pull updated location data from CEM
    Create a file and push to S3 - cg-vtec-prod/weather/reference/locations.dat

Fire a Lambda job at 00:30 which will start a script running on Prod SFTP
    Get the updated location file from S3
    For each line of the file get the five day forecast
        For each day, get the min/max temp and most common weather type
    Put the forecast into a file and push the file into S3

Run a script on Spectrum to pull down the updated forecasts from S3
Update the weather table with the new records & any changes to existing rows
"""
import boto3
import boto3.s3.transfer as tr
import requests
from datetime import datetime
from datetime import date
import csv
import time
from collections import defaultdict, Counter
import sys
import traceback

today = date.today().strftime('%Y%m%d')

API_KEY = '0f0eee53cb80d2272c12a87e87e8a609'

INPUT = 'locations.dat'

OUTPUT = 'five_day_forecast.dat'
OUTPUT_TO_S3 = 'five_day_forecast_{0}.dat'.format(today)
HEADER = ('location_id', 'date', 'weather_code', 'max_temp', 'min_temp')

TO_EMAIL = [#'steve.forster@cometgc.com',
            #'support.vtec@cometgc.com',
            'martin.campbell@cometgc.com']

FROM_EMAIL = 'spectrum_alerts@cg-vtec.co.uk'
SUBJECT = 'Weather API Processing'

DESTINATION_BUCKET = 'merkle-vtwc-dev'
DESTINATION_PREFIX = 'Extract/Weather'

access_key = 'ASIAJHB2YBPE7ZJO3TFQ'
secret_key = '/F9zBk0awa7X5P5xochS94ZLpIpiVsdgRXT260Cu'

email_events = []


def timeit(f):
    def timed(*args, **kw):
        ts = time.time()
        result = f(*args, **kw)
        te = time.time()
        print('%s took: %2.4f sec' % (f.__name__, te-ts))
        return result
    return timed


def ses_mail(email_events):
    ses = boto3.client('ses', region_name='eu-west-1')
    ses.send_email(
        Source=FROM_EMAIL,
        Destination={
            'ToAddresses': TO_EMAIL
        },
        Message={
            'Subject': {'Data': SUBJECT},
            'Body': {'Text': {'Data': "\n".join(email_events)}}
        }
    )


def read_input(input_file):
    """
    We create a generator for iterating through the input file.
    For the sort of file sizes we're looking at for Weather API this isn't
    really needed, but it is good practice to keep memory usage to a minimum if
    we can and this could be very handy for larger files in future.
    """
    with open(input_file, "r") as csvfile:
        datareader = csv.reader(csvfile)
        count = 0
        for row in datareader:
            if count == 0:
                count += 1
                continue
            else:
                count += 1
                yield row


def get_five_day_forecast(lat, lon):
    call = 'http://api.openweathermap.org/data/2.5/forecast?lat={0}&lon={1}&APPID={2}'.format(lat, lon, API_KEY)
    r = requests.post(call)

    return r


def process_api_results(res, location_id):
    api_results = []

    res_json = res.json()
    res_list = res_json['list']

    for i in res_list:
        dt = i['dt']
        forecast_date = datetime.fromtimestamp(int(dt)).strftime('%Y-%m-%d')
        forecast_time = datetime.fromtimestamp(int(dt)).strftime('%H:%M:%S')

        weather_code = i['weather'][0]['id']
        temp_kelvin = i['main']['temp']
        temp_celsius = "{0:.0f}".format(temp_kelvin - 273.15)

        api_results.append((location_id,
                            forecast_date,
                            forecast_time,
                            weather_code,
                            temp_celsius))
    return api_results


def produce_daily_summary(input_file):
    global email_events

    weather = defaultdict(lambda: defaultdict(list))
    temp = defaultdict(lambda: defaultdict(list))

    in_f = read_input(input_file)
    for row in in_f:
        location_id, longitude, latitude = row

        r = get_five_day_forecast(lat=latitude,
                                  lon=longitude)
        time.sleep(1.1)

        if r.status_code == 200:
            results = process_api_results(r, location_id)

            for r in results:
                weather[r[0]][r[1]].append(r[3])
                temp[r[0]][r[1]].append(int(r[4]))
        else:
            email_events.append("Error code {0} recieved for location_id {1}".format(r.status_code, location_id))
            print(r.status_code)
    email_events.append("Weather API pull complete")
    return weather, temp


def output_results(weather, temp):
    global email_events

    email_events.append("Starting results output")

    with open(OUTPUT, 'w') as f:
        f.write(",".join(HEADER))
        for loc in weather:
            for day in weather[loc]:
                f.write("\n")
                f.write(",".join(map(str, (loc,
                                           day,
                                           Counter(weather[loc][day]).most_common(1)[0][0],
                                           max(temp[loc][day]),
                                           min(temp[loc][day]))
                                     )))
    email_events.append("Results output completed")


def load_to_s3():
    global email_events

    email_events.append("Pushing weather file to S3")

    client = boto3.client('s3')
    #client = boto3.client('s3', aws_access_key_id=access_key,aws_secret_access_key=secret_key)
    transfer = tr.S3Transfer(client)
    transfer.upload_file(OUTPUT,
                         DESTINATION_BUCKET,
                         DESTINATION_PREFIX + '/' + OUTPUT_TO_S3)

    email_events.append("Weather file pushed to S3")


@timeit
def main():
    global email_events
    try:
        weather, temp = produce_daily_summary(input_file=INPUT)
        output_results(weather, temp)
        load_to_s3()
        #ses_mail(email_events)

    except Exception:
        print(sys.exc_info()[0])
        email_events.append(sys.exc_info()[0])

        print(traceback.format_exc())
        email_events.append(traceback.format_exc())
        ses_mail(email_events)

if __name__ == "__main__":
    main()
