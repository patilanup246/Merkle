#!/usr/bin/env python2.7

import sys,getopt
import os
import boto.sts
import boto.iam
import boto.s3
import boto
import requests
import getpass
import ConfigParser
import base64
import logging
import xml.etree.ElementTree as ET
import re
from bs4 import BeautifulSoup
from os.path import expanduser
from urlparse import urlparse, urlunparse
import codecs

##########################################################################
# Variables

# region: The default AWS region that this script will connect
# to for all API calls
region = 'us-east-1'

# output format: The AWS CLI output format that will be configured in the
# saml profile (affects subsequent CLI calls)
outputformat = 'json'

# awsconfigfile: The file where this script will store the temp
# credentials under the saml profile
awsconfigfile = '/.aws/credentials'

# SSL certificate verification: Whether or not strict certificate
# verification is done, False should only be used for dev/test
sslverification = True

# idpentryurl: The initial url that starts the authentication process.
idpentryurl = 'https://signon.merkleinc.com/idp/startSSO.ping?PartnerSpId=urn:amazon:webservices'
#idpentryurl = 'https://signontest.merkleinc.com/idp/startSSO.ping?PartnerSpId=urn:amazon:webservices'

# Uncomment to enable low level debugging
#logging.basicConfig(level=logging.DEBUG)

##########################################################################
global opts
global ALL_ACCOUNTS
global username
global password
global account
global role
global TTL
global tokens
global ROLE_ARN
global DEBUG

#SOME DEFAULTS
default_role='MerkleWebSSOAdmins'
ALL_ACCOUNTS=False
username=getpass.getuser().lower()
password=''
role=''
account=''
TTL=28880
ROLE_ARN=""
PROFILE_NAME=""
tokens={}
DEBUG=False
def print_debug(s):
    if DEBUG:
        print s

def update_profile(boto_profile,role_arn,principal_arn,assertion,token):
    #print "in update_profile", boto_profile
    # conn = boto.sts.connect_to_region(region,profile_name='default-stub')
    # try:
    #     token = conn.assume_role_with_saml(role_arn, principal_arn, assertion,duration_seconds=TTL)
    # except boto.exception.BotoServerError:
    #     print "Could not get tocken with ",TTL,"for ",awailable_role
    #     print "Reducing TTL to boto default and retrying"
    #     print "PLEASE CONSIDER CALLING THIS SCRIPT WITH '-t 3600` argument as the configuration does not seem to allow longer TTLs"
    #     token = conn.assume_role_with_saml(role_arn, principal_arn, assertion)

    home = expanduser("~")
    filename = home + awsconfigfile
    config = ConfigParser.RawConfigParser()
    config.read(filename)

    # Put the credentials into a saml specific section instead of clobbering
    # the default credentials
    if not config.has_section(boto_profile):

         config.add_section(boto_profile)
    print 'Updating ', boto_profile, 'profile for', role_arn
    config.set(boto_profile, 'output', outputformat)
    config.set(boto_profile, 'region', region)
    config.set(boto_profile, 'aws_access_key_id', token.credentials.access_key)
    config.set(boto_profile, 'aws_secret_access_key', token.credentials.secret_key)
    config.set(boto_profile, 'aws_session_token', token.credentials.session_token)

    # Write the updated config file
    with open(filename, 'w+') as configfile:
        config.write(configfile)

def init_config_file(configfile):
  if not os.path.exists(os.path.dirname(configfile)):
    try:
        os.makedirs(os.path.dirname(configfile))
    except OSError as exc: # Guard against race condition
        if exc.errno != errno.EEXIST:
            raise

  config = ConfigParser.RawConfigParser()
  config.read(filename)

  # Put the credentials into a saml specific section instead of clobbering
  # the default credentials
  if not config.has_section('default-stub'):
      print 'Adding default-stub boto profile'
      config.add_section('default-stub')
  config.set('default-stub', 'output', outputformat)
  config.set('default-stub', 'region', region)
  config.set('default-stub', 'aws_access_key_id', 'empty')
  config.set('default-stub', 'aws_secret_access_key', 'empty')
  config.set('default-stub', 'aws_session_token', 'empty')
  # else:
  #     print 'Using existing default-stub profile'

  # Write the updated config file
  with open(filename, 'w+') as configfile:
      config.write(configfile)
      configfile.close()

##get command line options into dictionary
def print_usage():
    #print "\n\n"
    print "USAGE:"
    print "\t",os.path.basename(sys.argv[0]),"[-u username -p password] [-r role_arn] [-A] [-a account] [-r role ] [-R role_arn] [-P profile_name] -t [TTL_in_seconds]"
    print "Where:"
    print "\t-u|--username <username>: Username of AD user to authenticate, defaults to the user who is calling the script"
    print "\t-p|--password <password>: User's password"
    print "\t-r|--role <role>: AWS IAM role to create credentials for, \n\t\t\tdefault is MerkleWebSSOAdmins"
    print "\t-a|--account <account>: account to login to"
    print "\t-A|--ALL_ACCOUNTS: create credentials for all accounts in which \n\t\t\tspecified with -r option role exists(or for default role)"
    print "\t-t|--TTL: specify time to leave for the authentication credentials. NOTE: if ttl exceedsmax allowed for the saml role, authentication will fail"
    print "\t-R|--ROLE_ARN <role_arn>: role ARN.    This option is MUTUALLY EXLUSIVE with -A -r -a options. Would only create profile for the role_arn specified"
    print "\t-P|--PROFILE_NAME <profile_name>: To be used in conjunction with -R|--ROLE_ARN options.   Specify boto profile to create/update"
    print "\t-h|--help: print this helpfull message "
    print "\t-d|--DEBUG: print some debgug outputs"
    sys.exit(0)

def getopts(argv):
        global opts
        global ALL_ACCOUNTS
        global username
        global password
        global account
        global role
        global TTL
        global ROLE_ARN
        global PROFILE_NAME
        global DEBUG

        #opts = {}
        try:

            opts, args = getopt.getopt(argv,"hu:p:a:Ar:t:R:P:d",["username=","password=","account=","role=","help","ALL_ACCOUNTS","TTL=","ROLE_ARN=","PROFILE_NAME=","DEBUG"])

        except getopt.GetoptError:
            print_usage()
        for opt, arg in opts:
            if opt in ("-h","--help"):
                print_usage();
            if opt in ("-u","--username"):
                username=arg;
            if opt in ("-p","--password"):
                password=arg;
            if opt in ("-r","--role"):
                role=arg;
            if opt in ("-a","--account"):
                account=arg;
            if opt in ("-t","--TTL"):
                TTL=arg;
            if opt in ("-A","--ALL_ACCOUNTS"):
                ALL_ACCOUNTS=True
            if opt in ("-R","--ROLE_ARN"):
                ROLE_ARN=arg;
            if opt in ("-P","--PROFILE_NAME"):
                PROFILE_NAME=arg;
            if opt in ("-d","--DEBUG"):
                DEBUG=True
getopts(sys.argv[1:])
# Initiate session handler
# Get the federated credentials from the user
if password is '':
    print "Username:", username
    password = getpass.getpass()
    print ''
session = requests.Session()
# Initiate default profile in config file, if does not exist
home = expanduser("~")
filename = home + awsconfigfile
init_config_file(filename)
# Programmatically get the SAML assertion
# Opens the initial IdP url and follows all of the HTTP302 redirects, and
# gets the resulting login page

formresponse = session.get(idpentryurl, verify=sslverification)
rurl = formresponse.url

formresponse2 = session.post(rurl, verify=sslverification)

# Capture the idpauthformsubmiturl, which is the final url after all the 302s
idpauthformsubmiturl = formresponse2.url

# Parse the response and extract all the necessary values
# in order to build a dictionary of all of the form values the IdP expects

retStringtmp = formresponse2.text.encode('ascii', 'ignore').decode('ascii')
#print(retStringtmp)
formsoup = BeautifulSoup(retStringtmp, "html.parser")
payload = {}

for inputtag in formsoup.find_all(re.compile('(INPUT|input)')):
    name = inputtag.get('name','')
    value = inputtag.get('value','')
    if "pf.username" in name.lower():
        #Make an educated guess that this is the right field for the username
        payload[name] = username
    elif "pf.pass" in name.lower():
        #Some IdPs also label the username field as 'email'
        payload[name] = password
    else:
        #Simply populate the parameter with the existing value (picks up hidden fields in the login form)
        payload[name] = value

payload["pf.ok"] = "clicked"
payload["pf.adapterId"] = "Pclc0HtmlOnly"

# Debug the parameter payload if needed
# Use with caution since this will print sensitive output to the screen
#print payload

# Some IdPs don't explicitly set a form action, but if one is set we should
# build the idpauthformsubmiturl by combining the scheme and hostname
# from the entry url with the form action target
# If the action tag doesn't exist, we just stick with the
# idpauthformsubmiturl above
for inputtag in formsoup.find_all(re.compile('(FORM|form)')):
    action = inputtag.get('action')
    if action:
        parsedurl = urlparse(idpentryurl)
        idpauthformsubmiturl = parsedurl.scheme + "://" + parsedurl.netloc + action

# Performs the submission of the IdP login form with the above post data
response = session.post(
    idpauthformsubmiturl, data=payload, verify=sslverification)

# Debug the response if needed
#print (response.text)

# Overwrite and delete the credential variables, just for safety
username = '##############################################'
password = '##############################################'
del username
del password

retString = response.text.encode('ascii', 'ignore').decode('ascii')
# Decode the response and extract the SAML assertion
soup = BeautifulSoup(retString, "html.parser")
#print retString
#soup = BeautifulSoup(response.text, "html.parser")
assertion = ''
#print soup

# Look for the SAMLResponse attribute of the input tag (determined by
# analyzing the debug print lines above)
for inputtag in soup.find_all('input'):
    if(inputtag.get('name') == 'SAMLResponse'):
        #print(inputtag.get('value'))
        assertion = inputtag.get('value')

#print assertion
# Better error handling is required for production use.
if (assertion == ''):
    #TODO: Insert valid error checking/handling
    print 'Response did not contain a valid SAML assertion'
    sys.exit(0)

# Debug only
print_debug("Assertion:\n\t" + base64.b64decode(assertion))

# Parse the returned assertion and extract the authorized roles
awsroles = []
root = ET.fromstring(base64.b64decode(assertion))
for saml2attribute in root.iter('{urn:oasis:names:tc:SAML:2.0:assertion}Attribute'):
    if (saml2attribute.get('Name') == 'https://aws.amazon.com/SAML/Attributes/Role'):
        for saml2attributevalue in saml2attribute.iter('{urn:oasis:names:tc:SAML:2.0:assertion}AttributeValue'):
            awsroles.append(saml2attributevalue.text)

# Note the format of the attribute value should be role_arn,principal_arn
# but lots of blogs list it as principal_arn,role_arn so let's reverse
# them if needed
for awsrole in awsroles:
    print_debug("Found awsrole:\t" + awsrole)
    chunks = awsrole.split(',')
    if'saml-provider' in chunks[0]:
        newawsrole = chunks[1] + ',' + chunks[0]
        index = awsroles.index(awsrole)
        awsroles.insert(index, newawsrole)
        awsroles.remove(awsrole)





# If I have more than one role, ask the user which one they want,
# otherwise just proceed
#if not ALL_ACCOUNTS or accounts undefined, print a list
#filtering out only aws roles that match given parameter

#if all ALL_ACCOUNTS is defined, and role NOT specified, assuming default role
# if ALL_ACCOUNTS and role == '':
#     role=default_role
subset_roles=[]

if ROLE_ARN !='':
    account_id=ROLE_ARN.split(':')[4]
    principal_arn="arn:aws:iam::"+account_id+":saml-provider/MerkleProdSSO"
    awsroles=[ROLE_ARN+","+principal_arn]




for awailable_role in awsroles:
    #filter by role
    if 'role/'+role in awailable_role:
        subset_roles.append(awailable_role)
awsroles=subset_roles
#this could use optimization
try:
    conn = boto.sts.connect_to_region(region,profile_name='default-stub')
except:
    print_debug("Failed to initialise connection:\t" + conn)
    raise

#filter by account
subset_roles=[]
for awailable_role in awsroles:
    role_arn = awailable_role.split(',')[0]
    account_id=role_arn.split(':')[4]
    principal_arn = awailable_role.split(',')[1]
    try:
        token = conn.assume_role_with_saml(role_arn, principal_arn, assertion,duration_seconds=TTL)
    except boto.exception.BotoServerError:
        #retrying with default TTL print "Coould not get tocken with ",TTL,"for ",awailable_role
        print "\tCoould not get token with ttl",TTL,"seconds for ",awailable_role
        print "\tReducing TTL to boto default and retrying"
        print "\tPLEASE CONSIDER CALLING THIS SCRIPT WITH '-t 3600` argument as the configuration does not seem to allow longer TTLs"
        print "\tThis message should go away after updated saml roles are pushed to all accounts\n\n\n"
        try:
            token = conn.assume_role_with_saml(role_arn, principal_arn, assertion)
        except:
            print "Failed to get credentials for " + role_arn + " and will skip it"
            continue

    except:
        print "Failed to get credentials for " + role_arn
        sys.exit(1)
    tokens[role_arn]=token



    # iam = boto3.client('iam',  aws_access_key_id=token.credentials.access_key, aws_secret_access_key=token.credentials.secret_key,    aws_session_token= token.credentials.session_token )
    # try :
    #     paginator = iam.get_paginator('list_account_aliases')
    #     for response in paginator.paginate():
    #         aliases=(response['AccountAliases'])
    #         alias=aliases[0]
    #         print alias
    # #if alias not defined or do not have permissions to get it
    # except:
    #     #if can not get actual alias, just use account ID
    #     alias=account_id
    try:
        iam=boto.connect_iam(aws_access_key_id=token.credentials.access_key, aws_secret_access_key=token.credentials.secret_key,security_token= token.credentials.session_token)
        alias=iam.get_account_alias().list_account_aliases_response.list_account_aliases_result.account_aliases[0]
    except:
        print_debug("Failed to get alias for :\t" + account_id + ".\tUsing account id as alias. ")
        alias=account_id


    awailable_role=awailable_role+','+alias
    if (alias == account or account == '') :
            subset_roles.append(awailable_role)
awsroles=subset_roles
#print awsroles
print ""
boto_profiles={}

if ALL_ACCOUNTS:
    for awailable_role in awsroles:
        role_arn = awailable_role.split(',')[0]
        principal_arn = awailable_role.split(',')[1]
        alias= awailable_role.split(',')[2]
        account_id=role_arn.split(':')[4]
        profile_role=role_arn.split('/')[1]
        # print profile_role
        if profile_role == default_role:
            # print "in default: \n\tprofile_role"+profile_role
            boto_profiles[alias+profile_role]=alias
        elif account_id+profile_role not in boto_profiles :
                # print "in if: \n\tprofile_role"+profile_role
            boto_profiles[alias+profile_role]=alias+"_"+profile_role
        else:
            boto_profiles[alias+profile_role]=alias
        if PROFILE_NAME !='' and len(awsroles)==1:
            update_profile(PROFILE_NAME,role_arn,principal_arn,assertion,tokens[role_arn])
        else:
            update_profile(boto_profiles[alias+profile_role],role_arn,principal_arn,assertion,tokens[role_arn])

        #print boto_profile
    #store last profile
    boto_profile=boto_profiles[alias+profile_role]
    #sys.exit(0)
else:
    if len(awsroles) > 1 :
        i = 0
        print "Please choose the role you would like to assume:"
                #print awsroles

        for awsrole in awsroles:
            role_arn = awsrole.split(',')[0]
            principal_arn = awsrole.split(',')[1]
            alias= awsrole.split(',')[2]
            account_id=awsrole.split(':')[4]
            profile_role=awsrole.split('/')[1]
            print '[', i, '] : ', awsrole.split(',')[2],"(",account_id,"): ", awsrole.split(',')[0].split('/')[1]
            i += 1
        print "Selection: ",
        selectedroleindex = raw_input()

         # Basic sanity check of input
        if int(selectedroleindex) > (len(awsroles) - 1):
            print 'You selected an invalid role index, please try again'
            sys.exit(0)

        role_arn = awsroles[int(selectedroleindex)].split(',')[0]
        principal_arn = awsroles[int(selectedroleindex)].split(',')[1]
        alias=awsroles[int(selectedroleindex)].split(',')[2]
	boto_profile=alias
        update_profile(boto_profile,role_arn,principal_arn,assertion,tokens[role_arn])
    elif len(awsroles) == 1:
        role_arn = awsroles[0].split(',')[0]
        principal_arn = awsroles[0].split(',')[1]
        alias=awsroles[0].split(',')[2]
            #print awsroles[0].split(',')[2]
        account_id=role_arn.split(':')[4]
        profile_role=role_arn.split('/')[1]
        boto_profile=alias
        if PROFILE_NAME !='':
            boto_profile=PROFILE_NAME

        update_profile(boto_profile,role_arn,principal_arn,assertion,tokens[role_arn])
    else:
        print 'Could not log in to any of the accounts/roles specified'
        sys.exit(1)
            # print role_arn
            # print principal_arn



    # Read in the existing config file

# Give the user some basic info as to what has just happened
print '\n\n----------------------------------------------------------------'
print 'Your new access key pair has been stored in the AWS configuration file {0} under'.format(filename),boto_profile,'profile'
print 'Note that it will expire at {0}.'.format(token.credentials.expiration)
print 'After this time, you may safely rerun this script to refresh your access key pair.'
print 'To use this credential, call the AWS CLI with the --profile option (e.g. aws --profile {0} ec2 describe-instances).'.format(boto_profile)
print '----------------------------------------------------------------\n\n'
