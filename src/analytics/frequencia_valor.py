# %% 
import pandas as pd
import sqlalchemy

import matplotlib.pyplot as plt

# %%

engine = sqlalchemy.create_engine("sqlite:///data/loyalty-system/database.db")
# %%
def import_query(path):
    with open(path) as open_file:
        return open_file.read()
    
query = import_query("src/analytics/frequencia_valor.sql")
# %%
df = pd.read_sql(query, engine)
df.head()
df = df[df['qtdPontosPositivos'] < 4000]
# %%

plt.plot(df['qtdeFrequencia'], df['qtdPontosPositivos'], 'o')
plt.grid()
plt.xlabel("Frequência")
plt.ylabel("Valor")
plt.show()
# %%

from sklearn import cluster
from sklearn import preprocessing

minmax = preprocessing.MinMaxScaler()

X = minmax.fit_transform(df[['qtdeFrequencia', 'qtdPontosPositivos']])

# %%

kmean = cluster.KMeans(n_clusters=5, random_state=42, max_iter=1000)

kmean.fit(X)

df['cluster_calc'] = kmean.labels_

df.groupby(by='cluster_calc')['IdCliente'].count()
# %%
import seaborn as sns

sns.scatterplot(data=df,
                x="qtdeFrequencia",
                y="qtdPontosPositivos",
                hue="cluster_calc",
                palette="tab10")

plt.hlines(y=1000, xmin=0, xmax=7, colors='black')
plt.hlines(y=1400, xmin=7, xmax=25, colors='black')
plt.vlines(x=3, ymin=0, ymax=1000, colors='black')
plt.vlines(x=7, ymin=0, ymax=3000, colors='black')

plt.grid()
# %%
