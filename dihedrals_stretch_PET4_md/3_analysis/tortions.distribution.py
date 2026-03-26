#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt 
# Enables Jupyter to display graphs
get_ipython().run_line_magic('matplotlib', 'inline')


# In[2]:


h1 = pd.read_csv("../2_md/4_md/md_01/COLVAR", sep="\s+", header=0, index_col=0, nrows=0)
hd = h1.columns.values.tolist()[1:]
# Energy - kJ/mol. Length - nanometers. Time - picoseconds
# LENGTH: nm (default), A (for Angstrom), um (for micrometer), Bohr (0.052917721067 nm)
# ENERGY: kj/mol (default), j/mol, kcal/mol (4.184 kj/mol), eV (96.48530749925792 kj/mol), Ha (for Hartree, 2625.499638 kj/mol)
# TIME: ps (default), fs, ns, atomic (2.418884326509e-5 ps)
# MASS: amu (default)
# CHARGE: e (default)
hdval = ['time [ps]', 'd1 [nm]', 't1 [deg]', 't2 [deg]', 't3 [deg]', 'lwall.bias [kj/mol]', 'lwall.force2 [?]']
hdval


# In[3]:


pet = list()
tors = list()

for i in range(0,19):
    pet.append("pet"+str(i+1).zfill(2))
    tors.append(pd.read_csv("../2_md/4_md/md_"+str(i+1).zfill(2)+"/COLVAR", sep="\s+", header=0, index_col=0, names=hdval, usecols=list(range(0,7))))
    tors[i] = tors[i].apply(pd.to_numeric, errors='coerce')
    tors[i] = tors[i].dropna()
    tors[i].iloc[:,1:4] = tors[i].iloc[:,1:4].apply(lambda x: x*180/np.pi)
data = dict(zip(pet, tors))
data

lwall = list()
t = list()
g = list()
r = list()
limit = [65,75,170,180]

for i in range(19):
    lwall.append(round(3.7-(.2*i),2))
    t.append(data[pet[i]][(data[pet[i]].iloc[:,1:4].abs()>=limit[2])&(data[pet[i]].iloc[:,1:4].abs()<=limit[3])].count().sum())
    g.append(data[pet[i]][(data[pet[i]].iloc[:,1:4].abs()>=limit[0])&(data[pet[i]].iloc[:,1:4].abs()<=limit[1])].count().sum())
    r.append(str(round(t[i]*100/(t[i] + g[i]),0))+" : "+str(round(g[i]*100/(t[i] + g[i]),0)))

#print(len(g))
#print(pet,t,g,lwall,r)
ratio = pd.DataFrame({"system":pet,"distance":lwall,"trans":t,"gauche":g,"ratio":r})
ratio#df['c'] = df.apply(lambda row: row.a + row.b, axis=1)
ratio.apply(lambda x: round(x.trans *100 / (x.gauche*100),2), axis=1)
# In[5]:


lwall = list()
t = list()
g = list()
r = list()
limit = [0,110,110,180]

for i in range(19):
    lwall.append(round(3.7-(.2*i),2))
    t.append(data[pet[i]][(data[pet[i]].iloc[:,1:4].abs()>=limit[2])&(data[pet[i]].iloc[:,1:4].abs()<=limit[3])].count().sum())
    g.append(data[pet[i]][(data[pet[i]].iloc[:,1:4].abs()>=limit[0])&(data[pet[i]].iloc[:,1:4].abs()<=limit[1])].count().sum())
    r.append(str(round(t[i]*100/(t[i] + g[i]),2))+" : "+str(round(g[i]*100/(t[i] + g[i]),2)))

#print(len(g))
#print(pet,t,g,lwall,r)
ratio = pd.DataFrame({"system":pet,"distance":lwall,"trans":t,"gauche":g,"ratio":r})
ratio


# In[57]:


trans = (ratio.trans *100 / (ratio.trans+ratio.gauche))
trans


# In[80]:


trans = (ratio.trans *100 / (ratio.trans+ratio.gauche))
gauche = (ratio.gauche *100 / (ratio.trans+ratio.gauche))

fig, ax1 = plt.subplots(figsize=(10,5))
#ax1.plot(ratio.distance, ratio.trans/ratio.gauche)
ax1.plot(ratio.distance, trans, color="orange",label='trans')
ax1.plot(ratio.distance, gauche, color="green",label="gauche")
ax1.plot(ratio.distance, ratio.trans/ratio.gauche,label="ratio",color="white")

ax1.set(xlabel='distance lwall (nm)', ylabel='ratio t / g (%)',
       title='Ratio trans-gauche vs lwall')
ax1.legend(loc='lower right')

ax2 = ax1.twinx()
ax2.set_ylabel('ratio')
ax2.plot(ratio.distance, ratio.trans/ratio.gauche,label="ratio")


fig.tight_layout()  # otherwise the right y-label is slightly clipped
plt.show()


# In[ ]:


data["pet01"].abs().mean()#.describe()#.iloc[:,1:4]


# In[ ]:


#df[(df['closing_price']>=99 ) & (df['closing_price']<=101)]
#data["pet01"].iloc[:,1:4]
data["pet01"][(data["pet01"].iloc[:,1:4].abs()>=170)&(data["pet01"].iloc[:,1:4].abs()<=180)].count()
t1 = data["pet01"][(data["pet01"].iloc[:,1:4].abs()>=170)&(data["pet01"].iloc[:,1:4].abs()<=180)].count().sum()

data["pet01"][(data["pet01"].iloc[:,1:4].abs()>=60)&(data["pet01"].iloc[:,1:4].abs()<=80)].count()
g1 = data["pet01"][(data["pet01"].iloc[:,1:4].abs()>=60)&(data["pet01"].iloc[:,1:4].abs()<=80)].count().sum()


# In[ ]:


print(str(round(t1*100/(t1 + g1),0))+":"+str(round(g1*100/(t1 + g1),0)))

data = pandas.DataFrame({'A' : ['X', 'Y'], 
                        'B' : 1, 
                        'C' : [2, 3]})
# In[ ]:


#df[(df['closing_price']>=99 ) & (df['closing_price']<=101)]
#data["pet01"].iloc[:,1:4]
data["pet01"][(data["pet01"].iloc[:,1:4].abs()>=160)&(data["pet01"].iloc[:,1:4].abs()<=180)].count()


# In[ ]:


t1 = data["pet01"][(data["pet01"].iloc[:,1:4].abs()>=160)&(data["pet01"].iloc[:,1:4].abs()<=180)].count().sum()


# In[ ]:


g1 = data["pet01"][(data["pet01"].iloc[:,1:4].abs()>=60)&(data["pet01"].iloc[:,1:4].abs()<=80)].count().sum()
data["pet01"][(data["pet01"].iloc[:,1:4].abs()>=60)&(data["pet01"].iloc[:,1:4].abs()<=80)].count()


# In[ ]:


t1/g1

deg = list()
for i in pet:
    #print(i,data[i])
    deg.append(data[i])
data_deg = dict(zip(pet, deg))#df["col"] = 2 * df["col"]
#data["pet19"].iloc[:,1:4] = data["pet19"].iloc[:,1:4].apply(lambda x: x*180/np.pi)
data["pet19"]#data["pet19"].iloc[:,[1,3]]
data["pet19"].iloc[:,1:4].apply(lambda x: x*180/np.pi)#.abs().count()#.describe()
#data["pet01"][]    #df[df["class"]==1].count()["value"]fig, axs = plt.subplots(5, 4,figsize=(15,15))
fig.suptitle('4xHEM torsions - t1 = blues - t2 = orange - t3 = green', fontsize=30)

count=0
for i in range(5):
    for j in range(4):
        count+=1
        if count < 20:
            #print(i,j,count,pet[count-1])
            k = pet[count-1]
            axs[i,j].hist(data[k].iloc[:,1].apply(lambda x: x*180/np.pi),150)#,color="tab:blue")
            axs[i,j].hist(data[k].iloc[:,2].apply(lambda x: x*180/np.pi),150)#,color="tab:orange")
            axs[i,j].hist(data[k].iloc[:,3].apply(lambda x: x*180/np.pi),150)#,color="tab:green")
            axs[i,j].set_title(k, fontsize=20)
        else:
            axs[i,j].axis('off')

fig.tight_layout()
plt.show()fig, axs = plt.subplots(5, 4,figsize=(15,15))
fig.suptitle('4xHEM torsions - t1 = blues - t2 = orange - t3 = green', fontsize=30)

count=0
for i in range(5):
    for j in range(4):
        count+=1
        if count < 20:
            #print(i,j,count,pet[count-1])
            k = pet[count-1]
            axs[i,j].plot(data[k].iloc[:,1:4])#,150, density = True, histtype='step', fill=False)#,color="blue")
            #axs[i,j].hist(data[k].iloc[:,2].apply(lambda x: x*180/np.pi).abs(),150, density = True, histtype='step',color="orange")
            #axs[i,j].hist(data[k].iloc[:,3].apply(lambda x: x*180/np.pi).abs(),150, density = True, histtype='step',color="green")
            axs[i,j].set_xlabel('degrees')
            axs[i,j].set_ylabel('Probability density')
            axs[i,j].set_title(k, fontsize=20)
        else:
            axs[i,j].axis('off')

fig.tight_layout()
plt.show()
#plt.savefig("pet01-pet19.png")
# In[ ]:


fig, axs = plt.subplots(5, 4,figsize=(15,15))
fig.suptitle('4xHEM torsions - t1 = blues - t2 = orange - t3 = green', fontsize=30)

count=0
for i in range(5):
    for j in range(4):
        count+=1
        if count < 20:
            #print(i,j,count,pet[count-1])
            k = pet[count-1]
            axs[i,j].hist(data[k].iloc[:,1:4],150, density = True, histtype='step', fill=False)#,color="blue")
            #axs[i,j].hist(data[k].iloc[:,2].apply(lambda x: x*180/np.pi).abs(),150, density = True, histtype='step',color="orange")
            #axs[i,j].hist(data[k].iloc[:,3].apply(lambda x: x*180/np.pi).abs(),150, density = True, histtype='step',color="green")
            axs[i,j].set_xlabel('degrees')
            axs[i,j].set_ylabel('Probability density')
            axs[i,j].set_title(k, fontsize=20)
        else:
            axs[i,j].axis('off')

fig.tight_layout()
plt.show()
#plt.savefig("pet01-pet19.png")


# In[ ]:


data[pet[0]].iloc[:,0]


# In[ ]:


data[pet[0]].iloc[:,0:4]


# In[ ]:


fig, axs = plt.subplots()#5, 4,figsize=(15,15))

plt.hist2d(data[pet[0]].iloc[:,0], data[pet[0]].iloc[:,1])#:4])

plt.show()

fig, axs = plt.subplots(5, 4,figsize=(15,15))
fig.suptitle('4xHEM torsions - t1 = blues - t2 = orange - t3 = green', fontsize=30)

count=0
for i in range(5):
    for j in range(4):
        count+=1
        if count < 20:
            #print(i,j,count,pet[count-1])
            k = pet[count-1]
            axs[i,j].hist(data[k].iloc[:,1:3].apply(lambda x: x*180/np.pi).abs(),150)#,color="tab:blue")
#            axs[i,j].hist(data[k].iloc[:,2]*180/np.pi,150)#,color="tab:orange")
#            axs[i,j].hist(data[k].iloc[:,3]*180/np.pi,150)#,color="tab:green")
            axs[i,j].set_title(k, fontsize=20)
        else:
            axs[i,j].axis('off')

fig.tight_layout()
plt.show()fig, axs = plt.subplots(2, 2,figsize=(5,5), subplot_kw=dict(projection='polar'))
fig.suptitle('4xHEM torsions')

count=0
for i in range(2):
    for j in range(2):
        count+=1
        if count < 20:
            #print(i,j,count,pet[count-1])
            x = pet[count-1]
            axs[i,j].hist(data[x][["t1"]],150)
            axs[i,j].hist(data[x][["t2"]],150)
            axs[i,j].hist(data[x][["t3"]],150)
            axs[i,j].set_ylabel(x)
        else:
            axs[i,j].axis('off')

fig.tight_layout()
plt.show()