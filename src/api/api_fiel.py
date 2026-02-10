from flask import Flask, request
import mlflow
import pandas as pd

mlflow.set_tracking_uri("http://localhost:5000/")

versions = mlflow.search_model_versions(filter_string="name='model_fiel'")
last_version = max([int(i.version) for i in versions])
model = mlflow.sklearn.load_model(f"models:///model_fiel/{last_version}")

app = Flask(__name__)

@app.route("/health_check")
def hello_world():
    return "Hello World!"

@app.route("/predict", methods=['POST'])
def predict():

    try:
        data = request.json['data']
        df = pd.DataFrame([data])
        X = df[model.feature_names_in_]
        predict = model.predict_proba(X)[:,1]
        return {'IdCliente':data['IdCliente'],"score":float(predict)}
    except:
        return request.json
    
@app.route("/predict_many", methods=['POST'])
def predict_many():

    try:
        data = request.json['data']
        df = pd.DataFrame(data)
        X = df[model.feature_names_in_]
        df['score'] = model.predict_proba(X)[:,1]
        resp = df[['IdCliente','score']].to_dict(orient='records')
        return {'score':resp}
    except:
        return request.json
