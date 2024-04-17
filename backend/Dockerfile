# Use the official Python base image
FROM python:3.12

# Set the working directory
RUN mkdir /app
WORKDIR /app

# Copy the application code
COPY . /app/
RUN pip install -r requirements.txt

# Expose the port the app will run on
EXPOSE 8000