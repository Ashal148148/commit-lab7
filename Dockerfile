FROM python:3.12.9-alpine
COPY src/* .
COPY requirements.txt .
RUN pip install -r requirements.txt
CMD ["python", "main.py"]