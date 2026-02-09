# %%
import pandas as pd
import sqlalchemy

from feature_engine import encoding, selection, imputation
from sklearn import ensemble, metrics, model_selection,pipeline, tree

import matplotlib.pyplot as plt
import mlflow


mlflow.set_tracking_uri("http://localhost:5000/")
mlflow.set_experiment(experiment_id=1)

pd.set_option('display.max_rows',None)
# %%
conn = sqlalchemy.create_engine("sqlite:///data/analytics/database.db")
# %%
# SAMPLE - Import dos dados

df = pd.read_sql("select * from abt_fiel", conn)
df.head()

# %%

# SAMPLE -- Out of Time (oot)

df_oot = df[df['dtRef'] == df["dtRef"].max()].reset_index(drop=True)
df_oot
# %%

# SAMPLE - Teste e Treino

target = 'flFiel'

features = df.columns.tolist()[3:]

df_train_test = df[df['dtRef'] < df['dtRef'].max()].reset_index(drop=True)

X = df_train_test[features]
y = df_train_test[target]
# %%

X_train, X_test, y_train, y_test = model_selection.train_test_split(
    X, y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

print(f"Base Treino: {y_train.shape[0]} Unid. | Tx. Target {100*y_train.mean():.2f}%")
print(f"Base Treino: {y_test.shape[0]} Unid. | Tx. Target {100*y_test.mean():.2f}%")
# %%
# EXPLORE -- MISSING

s_nas = X_train.isna().mean()
s_nas = s_nas[s_nas > 0]
s_nas
# %%
## EXPLORE -- BIVARIADA

cat_features = ['descLifeCycleAtual','descLifeCycleD28']
num_features = list(set(features) - set(cat_features))
num_features

df_train = X_train.copy()
df_train[target] = y_train.copy()

df_train[num_features] = df_train[num_features].astype(float)

bivariada = df_train.groupby(target)[num_features].median().T
bivariada['ratio'] = (bivariada[1] + 0.001) / (bivariada[0] + 0.001)
bivariada.sort_values(by='ratio', ascending=False)

to_remove = bivariada[bivariada['ratio'] == 1].index.tolist()
# %%
df_train.groupby('descLifeCycleAtual')[target].mean()

# %%
df_train.groupby('descLifeCycleD28')[target].mean()

# %%

# MODIFY -- DROP
X_train[num_features] = X_train[num_features].astype(float)

drop_features = selection.DropFeatures(to_remove)

# %%
# MODIFY -- FILL NA
fill_0 = ['github2025','python2025']

imput_0 = imputation.ArbitraryNumberImputer(arbitrary_number=0, variables=fill_0)

imput_new = imputation.CategoricalImputer(fill_value='Nao-Usuario',
                                          variables=['descLifeCycleD28'])

imput_1000 = imputation.ArbitraryNumberImputer(
    arbitrary_number=1000,
    variables=['avgIntervaloDiasVida','avgIntervaloDiasD28','qtdDiasUltAtividade']
    )

# %%
# MODIFY -- ONEHOT
onehot = encoding.OneHotEncoder(variables=cat_features)

# %%
# MODEL

#model = tree.DecisionTreeClassifier(random_state=42,
#                                    min_samples_leaf=50)
model = ensemble.RandomForestClassifier(random_state=42,
                                        n_estimators=150,
                                        n_jobs=1,
                                        min_samples_leaf=60)
# %%
# Criando PIPELINE
model_pipeline = pipeline.Pipeline(steps=[
    ('Remoção de Features', drop_features),
    ('Imputação de Zeros',imput_0),
    ('Imputação de Nao-Usuario', imput_new),
    ('Imputação de 1000', imput_1000),
    ('OneHotEncoding', onehot),
    ('Algoritmo', model)
])

with mlflow.start_run() as r:

    mlflow.sklearn.autolog()

    model_pipeline.fit(X_train, y_train)

    # ASSESS - Métricas

    y_pred_train = model_pipeline.predict(X_train)
    y_proba_train = model_pipeline.predict_proba(X_train)

    acc_train = metrics.accuracy_score(y_train, y_pred_train)
    auc_train = metrics.roc_auc_score(y_train, y_proba_train[:,1])
    print("Acurácia Treino:", acc_train)
    print("AUC Treino:", auc_train)

    y_pred_test = model_pipeline.predict(X_test)
    y_proba_test = model_pipeline.predict_proba(X_test)

    acc_test = metrics.accuracy_score(y_test, y_pred_test)
    auc_test = metrics.roc_auc_score(y_test, y_proba_test[:,1])
    print("Acurácia Teste:", acc_test)
    print("AUC Teste:", auc_test)

    # BASELINE

    y_pred_base = pd.Series([0]* y_test.shape[0])
    y_proba_base = pd.Series([y_train.mean()]*y_test.shape[0])

    acc_base = metrics.accuracy_score(y_test, y_pred_base)
    auc_base = metrics.roc_auc_score(y_test, y_proba_base)
    print("Acurácia Baseline:", acc_base)
    print("AUC Baseline:", auc_base)

    X_oot = df_oot[features]
    y_oot = df_oot[target]

    y_pred_oot = model_pipeline.predict(X_oot)
    y_proba_oot = model_pipeline.predict_proba(X_oot)

    acc_oot = metrics.accuracy_score(y_oot, y_pred_oot)
    auc_oot = metrics.roc_auc_score(y_oot, y_proba_oot[:,1])
    print("Acurácia OOT:", acc_oot)
    print("AUC OOT:", auc_oot)

    mlflow.log_metrics({
        "acc_train": acc_train,
        "auc_train": auc_train,
        "acc_test": acc_test,
        "auc_test": auc_test,
        "acc_oot": acc_oot,
        "auc_oot": auc_oot,
    })

    roc_train = metrics.roc_curve(y_train, y_proba_train[:,1])
    roc_test = metrics.roc_curve(y_test, y_proba_test[:,1])
    roc_oot = metrics.roc_curve(y_oot, y_proba_oot[:,1])

    plt.figure(dpi=200)

    plt.plot(roc_train[0],roc_train[1])
    plt.plot(roc_test[0],roc_test[1])
    plt.plot(roc_oot[0],roc_oot[1])

    plt.legend([
        f"Treino: {auc_train:.4f}",
        f"Teste: {auc_test:.4f}",
        f"OOT: {auc_oot:.4f}"
    ])

    plt.plot([0,1],[0,1], '--', color='black')
    plt.grid(True)
    plt.title("Curva ROC")
    plt.savefig("img/curva_roc.png")

    mlflow.log_artifact('img/curva_roc.png')
# %%
features_names = (model_pipeline[:-1].transform(X_train)
                    .columns
                    .tolist())

feature_importance = pd.Series(model.feature_importances_, index=features_names)
feature_importance.sort_values(ascending=False)
