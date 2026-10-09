FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

CMD [ "strands-decider", "serve", "StrandsAgents/strands-decider-2B-hobson-v21", "--host", "0.0.0.0", "--port", "8000" ]

EXPOSE 8000
