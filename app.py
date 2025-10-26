# load
import joblib
pipeline = joblib.load('model_pipeline.joblib')

# in predict endpoint
df = pd.DataFrame([payload])   # raw payload with 'Neighborhood' and 'Brick' as before
pred = pipeline.predict(df)[0]
