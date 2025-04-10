# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Copy the current directory contents into the container at /app
COPY main.py main.py

# Run app.py when the container launches
CMD ["python", "main.py"]