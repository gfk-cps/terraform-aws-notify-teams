#!/usr/bin/env python3.9

import time
import json   
import requests
import os
from datetime import datetime

def is_time_between(begin_time, end_time, check_time=None):
    # If check time is not given, default to current UTC time
    check_time = check_time or datetime.utcnow().time()
    if begin_time < end_time:
        return check_time >= begin_time and check_time <= end_time
    else: # crosses midnight
        return check_time >= begin_time or check_time <= end_time

def lambda_handler(event, context):

    message = event
    alarm_name = json.loads(message)['AlarmName']
    alarm_desc = json.loads(message)['AlarmDescription']
    new_state = json.loads(message)['NewStateValue']
    alarm_time = json.loads(message)['StateChangeTime']
    region = json.loads(message)['Region']
    account_id = context.invoked_function_arn.split(':')[4]
    
    # Create url link to view alarm
    alarm_url = f"https://console.aws.amazon.com/cloudwatch/home?region={region}#s=Alarms&alarm={alarm_name}"
    
    # Setting the theme color for the Teams message based on the new state of the alarm
    if new_state == "ALARM":
        colour = "FF0000"
    elif new_state == "OK":
        colour = "00FF00"
    else:
        colour = "0000FF"
    
    # Constructing the Teams message payload for an alarm
    message_card = {
        "@type": "MessageCard",
        "@context": "http://schema.org/extensions",
        "themeColor": colour,
        "title": f"{alarm_name} {new_state}",
        "text": f"Alarm description: {alarm_desc}\nCurrent state: {new_state}\nTriggered time: {alarm_time}",
        "potentialAction": [
            {
                "@type": "OpenUri",
                "name": f"View Alarm {account_id}",
                "targets": [
                    {
                        "os": "default",
                        "uri": alarm_url
                    }
                ]
            }
        ]
    }
    
    # Sending the Teams message to the specified webhook URL
    webhook_url = os.environ['TEAMS_WEBHOOK_URL']
    headers = {
      'Content-Type': 'application/json'
    }

    # Only send out notifications during service times
    # Covert 16:00 to time(16,00) from ENV Variables
    start_hour = int(os.environ['NOTIFICATION_BEGIN'].split(sep=":")[0])
    start_minute = int(os.environ['NOTIFICATION_BEGIN'].split(sep=":")[1])
    end_hour = int(os.environ['NOTIFICATION_END'].split(sep=":")[0])
    end_minute = int(os.environ['NOTIFICATION_END'].split(sep=":")[1])

    # check if current time is in service time window
    if is_time_between(time(start_hour,start_minute), time(end_hour,end_minute)):
      response = requests.post(webhook_url, json=message_card, headers=headers)
