# kubeflow_pipeline.py
import kfp
from kfp import dsl
from kfp.dsl import component

@component
def preprocess_op(data_path: str, output_path: str):
    import pandas as pd
    df = pd.read_csv(data_path)
    df['Brick'] = df['Brick'].map({'Yes':1,'No':0})
    df = pd.get_dummies(df, columns=['Neighborhood'], drop_first=True)
    df.to_csv(output_path, index=False)

@component
def train_op(processed_path: str, model_path: str):
    import pandas as pd
    from sklearn.ensemble import RandomForestRegressor
    from sklearn.model_selection import train_test_split
    import joblib
    df = pd.read_csv(processed_path)
    X = df.drop('Price', axis=1)
    y = df['Price']
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    joblib.dump(model, model_path)

@dsl.pipeline(
    name='House price pipeline',
    description='Preprocess, train and store model'
)
def house_pipeline(
    data_path: str = '/data/house.csv',
    processed_path: str = '/data/processed.csv',
    model_path: str = '/data/model.joblib'
):
    p = preprocess_op(data_path=data_path, output_path=processed_path)
    t = train_op(processed_path=p.outputs['output_path'], model_path=model_path)

if __name__ == '__main__':
    kfp.compiler.Compiler().compile(house_pipeline, 'house_pipeline.yaml')
