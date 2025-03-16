from nicegui import ui
import boto3

# Don't specify credentials in order to use the default ones that exist on the ECS task
s3_client = boto3.client('s3')
# Get the object from the bucket
s3_object = s3_client.get_object(Bucket='ashal-lab7-s3', Key='logo192.png')
logo = s3_object['Body'].read()
# Save it to disk in order to serve it as a static resource
with open('logo', 'wb') as f:
   f.write(logo)
# Cleanup
del s3_client
del s3_object
del logo

# Create the UI
with ui.column().classes('items-center w-full'):
    ui.label('Hello Commit').classes('text-red text-7xl')
    ui.image('logo').classes('w-96')

ui.run(reload=False)