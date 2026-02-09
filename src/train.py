# %%
import pandas as pd
import sqlalchemy

from feature_engine import encoding, selection, imputation
from sklearn import model_selection

pd.set_option('display.max_rows',None)
# %%
conn = sqlalchemy.create_engine("sqlite:///data/analytics/database.db")
# %%
# SAMPLE - Import dos dados

df = pd.read_sql("abt_fiel", conn)
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

# MODIFY -- Aplicando as transformações
X_train_transform = drop_features.fit_transform(X_train)
X_train_transform = imput_0.fit_transform(X_train_transform)
X_train_transform = imput_new.fit_transform(X_train_transform)
X_train_transform = imput_1000.fit_transform(X_train_transform)
X_train_transform = onehot.fit_transform(X_train_transform)

# %%
X_train_transform.head()
# %%
