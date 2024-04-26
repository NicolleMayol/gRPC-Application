# Use the official Python image as base
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code into the container
COPY . .

# Expose port 50051
EXPOSE 50051

# Command to run the application
CMD ["python", "app.py"]
