import sys
import os.path
from datetime import datetime, timedelta, UTC
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from zoneinfo import ZoneInfo

# Config
SCOPES = ['https://www.googleapis.com/auth/calendar.readonly']

#Google Calendar API Credential
CLIENT_SECRET_FILE = os.path.expanduser('~/.config/conky/Shelyak-Dark/scripts/credentials.json')

# File where the token will be stored
TOKEN_FILE = os.path.expanduser('~/.config/conky/Shelyak-Dark/scripts/token.json')  

TIMEZONE = ZoneInfo("America/Sao_Paulo")

def get_authenticated_service():
    creds = None
    
    # Checks if a valid token already exists
    if os.path.exists(TOKEN_FILE):
        creds = Credentials.from_authorized_user_file(TOKEN_FILE, SCOPES)
    
    # If there is no valid token or it is expired
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(CLIENT_SECRET_FILE, SCOPES)
            creds = flow.run_local_server(port=0)
        
        # Saves token for future use
        with open(TOKEN_FILE, 'w') as token:
            token.write(creds.to_json())
    
    return build('calendar', 'v3', credentials=creds)

def get_today_events():
    service = get_authenticated_service()

    # Set time range (today)
    time_min = datetime.now(TIMEZONE).date().isoformat() + 'T00:00:00-03:00'
    time_max = (datetime.now(TIMEZONE) + timedelta(days=1)).date().isoformat() + 'T00:00:00-03:00'
    
    # Search events
    events_result = service.events().list(
        calendarId='primary',
        timeMin=time_min,
        timeMax=time_max,
        singleEvents=True,
        orderBy='startTime'
    ).execute()
    
    return events_result.get('items', [])

def format_event_time(event):
    start = event.get('start', {}).get('dateTime', event.get('start', {}).get('date'))
    if not start: 
        #for events without a timetable
        return "Sem Horário"

    try:
        #For events with specific times
        dt = datetime.fromisoformat(start)
        return dt.strftime("%H:%M")
    except ValueError:
        #for full day events
        return "Dia Inteiro"

def main():
    if len(sys.argv) <= 1:
        print("Nenhum parâmetro fornecido.")
        return

    option = sys.argv[1]
    events = get_today_events()

    if option == "-n":
        # Displays the name of the first event of the day, or message if none exists
        if events:
            first_event = events[0]
            event_name = first_event.get('summary', 'Evento sem nome')
            print(event_name)
        else:
            print("Nenhum evento.")

    elif option == "-t":
        # Displays the time of the first event of the day, but shows nothing if there is none
        if events:
            first_event = events[0]
            event_time = format_event_time(first_event)
            print(event_time)

    else:
        print("Parâmetro inválido.")

if __name__ == '__main__':
    main()
    
