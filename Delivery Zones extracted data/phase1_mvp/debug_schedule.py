from phpserialize import loads
import json

with open('mvp_blob_delivery_schedule.json') as f:
    data = json.load(f)

blob = data[0]['blob_data'].replace('\\"', '"')
schedule = loads(blob.encode())

print("Keys in schedule:", list(schedule.keys())[:10])
print("\nhas 'start'?", 'start' in schedule or b'start' in schedule)
print("has b'start'?", b'start' in schedule)

if b'start' in schedule:
    print("\nKeys in start:", list(schedule[b'start'].keys())[:10])
    print("\nSample day data:")
    first_day = list(schedule[b'start'].keys())[0]
    print(f"  Day: {first_day}")
    print(f"  Data: {schedule[b'start'][first_day]}")








