FROM python:3.10

WORKDIR /app

COPY main.py /app

RUN pip install fastapi uvicorn

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
