# Base de données: Enquêtes Emploi réalisées par l’Insee en 2015 et 2016.#
# Champ de l'étude :  Salariés en France de 1962 à 2016.
############################################
# 1. Exploration et description de la base #
############################################
# Appel des librairies #
library(dplyr)
library(ggplot2)
library(tidyverse)
library(oaxaca)
library(tableone)
library(forcats)

# Stockage des dataset dans deux objets #
db_2015 <- enq_emploi_salarie_2015
db_2016 <- enq_emploi_salarie_2016

# Consolidation des deux dataset #
db <- rbind(db_2015, db_2016)

# Synthèse des caractériques des variables des dataset #
# Caractéristiques des tables #
str(db_2015)
str(db_2016)
str(db)

#Les bases originales ont été traitées càd que les valeurs aberrantes et manquantes ont été omises.
#La base consolidée contient 48 489 observations représentant des salariés français de 2015 et de 2016 et 18 variables (12 qualitatives et 6 quantitatives):
# Variables qualitatives:
# > "lnais" indique Lieu de naissance de l’enquête contient 2 modalités (1= français | 2= étranger).
# > "nfrred" spécifie la nationalité de l’enquêté contient 3 modalités (1= français de naissance | 2= français par naturalisation | 3= étranger).
# > "naiper" indique le lieu de naissance du père contient 2 modalités (1= français | 2= étranger).
# > "nfrp" spécifie la nationalité du père contient (1= français de naissance | 2= français par naturalisation | 3= étranger).
# > "naimer" indique le lieu de naissance de la mère contient 2 modalités (1= français | 2= Etranger).
# > "nfrm" spécifie la nationalité de la mère contient 3 modalités (1= français de naissance | 2= français par naturalisation | 3= étranger).
# > "sexe" spécifie le sexe de l'individu contient 2 modalités (1= popnonimmigreeme | 2= popimmigreeme)
# > "ddipl" indique le diplôme le plus élevé obtenu contient 7 modalités ordinales (1= diplôme>Bac+2 | 3= diplôme:Bac+2 | 4= diplôme:Bac ou brevet | 5= diplôme:CAP,BEP | 6= diplôme:brevet des collèges | 7= diplôme:si aucun diplôme ou CEP)
# > "couple" indique le statut marital contient 2 modalités ordinales (1= Couple  | 2= Seul)
# > "cstotr" indique la catégorie socio-professionnelle contient 4 modalités ordinales (1= Cadre | 2= Profession intermédiaire | 3= Employé | 4= Ouvrier ) 
# > "horaic" indique la nature des horaires contient 3 modalités ordinales (1= horaires hebdomadaires popnonimmigreeogènes | 2= horaires alternés | 3= horaires variables )
# > "nuitc" indique Travail de nuit contient 3 modalités ordinales (1= travail de nuit plus de la moitié du temps | 2=  travail de nuit moins de la nuit | 3= pas de travail de nuit)
# Variables quantitatives:
# > "salaire" indique le salaire mensuel net retiré de la profession principale, corrigé des valeurs aberrantes et manquantes.
# > "heures" spécifie le nombre d’heures travaillées en moyenne par mois dans l’emploi principal (heures supplémentaires comprises), corrigé des valeurs aberrantes et manquantes. 
# > "date" indique l'année de début dans l’entreprise.
# > "age" renseigne l'âge en années.
# > "annee_enq" renseigne l'année d’enquête.

###############
# Question n°2#
###############

# Déterminer la part d'immigrés dans la population active française

# > Selon la définition de l'Insee un immigré est une personne née étrangère à l'étranger et résidant en France. Les personnes nées françaises à l'étranger et vivant en France ne sont donc pas comptabilisées.#
# > Six variables mobilisées relatives à l'origine "immigrée" ou "non française" de l'enquêté: "lnais", "nfrred", "naimer", "nfrred", "naiper", "nfrp" 

# a. Analyse descriptive

# Création d'une nouvelle variable catégorielle relative à l'origine des enquêtés, elle prend la modalité "1" quand l'enquêté est immigré sinon "0" quand il est né en France.
db$poporigine <- ifelse((db$lnais=="2" & db$nfrred!="1") | (db$lnais=="1" & db$nfrred=="1") & ((db$naimer=="2" & db$nfrm!="1") | (db$naiper=="2" & db$nfrp!="1")),1,0)

# Restitution d'un tableau de contingence (tri croisé) indiquant la part relative à la population immigrée dans la population.
table(db$poporigine)

# Restitution d'un tableau de contingence (tri croisé) indiquant la part relative à la population immigrée dans la population active.
prop.table(table(db$poporigine))
print(prop.table(table(db$poporigine)))
# > Interprétations: 16,49% des enquêtés est d'origine immigrée.

# Analyser l'écart de salaire moyen entre la population immigrée et la population née en France  

# Calcul de la moyenne de salaire entre les deux populations.
summarise(group_by(db,poporigine),mean(salaire))
# > Interprétations: 
# - La population immigrée perçoit un salaire mensuel moyen de 1 644€.
# - La population née en France perçoit un salaire mensuel moyen de 1 793€.
# - La population immigrée perçoit un salaire mensuel moyen 9,07% plus faible par rapport à la population née en France.

# Création de deux tables distinctes échantillonnées: la population immigrée (modalité "1") et de la population née en France (modalité "0").
db_popimmigree <- subset(db,db$poporigine==1)
db_popfrancais <- subset(db,db$poporigine==0)

# Création d'une variable dichotomique relative au lieu de naissance de l'individu, modalité "1" si il est né à l'étranger sinon "0" si il est né en France. 
db$lieunais <- ifelse(db$lnais=="2",1,0)

# Restitution d'un tableau de contingence (tri croisé) indiquant la part relative de la population immigrée dans la population
prop.table(table(db$lieunais))
print(prop.table(table(db$lieunais)))
# > Interprétations: 90% des individus sont nés en France et 10% des individus sont nés à l'étranger.

## Test d'hypothèse
# Test d'égalité des variances (Test de Fisher) salariales des deux sous-échantillons.
var.test(db_popimmigree$salaire,db_popfrancais$salaire)
# > Interprétations:La p-value est = 0,000229 (< 0,05) par conséquent on accepte l'hypothèse alternative (H1), les variances ne sont pas égales.

# Test d'égalité des moyennes (Test de student) salariales des deux sous-échantillons (à variances non égales).
t.test(db_popimmigree$salaire,db_popfrancais$salaire,paired=F,var.equal=F,alternative="two.sided",conf.level=0.95)
# > Interprétations:La p-value est = 2.2e-16* (< 0,05) par conséquent on accepte l'hypothèse alternative (H1) et on rejette l'hypothèse nulle selon laquelle les salaires des deux groupes sont égaux.
# - La population immigrée et la population née en France perçoivent des salaires significativement différents de zéro au seuil de 5%.
# - Dans 95% des cas, il est probable que les écarts de rémunération entre la population immigrée et celle née en France soient réels. 
#*Très proche de zero

# Comparaison de la distribution des salaires entre la population immigrée et de la population née en France.
summary(db_popimmigree$salaire)
summary(db_popfrancais$salaire)

# Visualisation graphique via des boîtes à moustaches.
db$poporigine_graph <- factor(db$poporigine,c("1","0"),labels=c("Immigrée","née en France"))
ggplot(db)+aes(y=salaire,x=poporigine_graph)+geom_boxplot()+xlab("")+ylab("Salaire mensuel")+ggtitle("Salaire mensuel selon l'origine")
# > Interprétations: 
# - Salaires plus dispersés pour la population immigrée que la population née en France.
# - Il y a très peu de valeurs atypiques car la base a été nettoyée, néanmoins on constate trois enquêtés nés en France perçoivent des salaires > à 7 000€.

###############
# Question n°3#
###############

# Déterminer quels sont les  différences plus significatives expliquant l'écart salarial entre les deux populations (Immigrées et née en France)

## Analyser l'écart moyen des différentes caractéristiques entre la population immigrée et la population née en France

# Conversion de la variable "années" en nombre d'années (population)
db$datantn <- as.numeric(as.character(db$datant))
# Création de la variable 'ancienneté' (population)
db$anc <- db$annee_enq - db$datantn

# Conversion de la variable "années" en nombre d'années (échantillon immigré)
db_popimmigree$datantn <- as.numeric(as.character(db_popimmigree$datant))
# Création de la variable 'ancienneté' (échantillon immigré)
db_popimmigree$anc <- db_popimmigree$annee_enq - db_popimmigree$datantn

# Conversion de la variable "années" en nombre d'années (échantillon français)
db_popfrancais$datantn <- as.numeric(as.character(db_popfrancais$datant))
# Création de la variable 'ancienneté' (échantillon français)
db_popfrancais$anc <- db_popfrancais$annee_enq - db_popfrancais$datantn

# Moyenne des variables
# Moyenne des variables catégorielles par échantillon.
prop.table(table(db_popimmigree$sexe))
prop.table(table(db_popfrancais$sexe))
prop.table(table(db_popimmigree$couple))
prop.table(table(db_popfrancais$couple))
prop.table(table(db_popimmigree$ddipl))
prop.table(table(db_popfrancais$ddipl))
prop.table(table(db_popimmigree$cstotr))
prop.table(table(db_popfrancais$cstotr))
prop.table(table(db_popimmigree$horaic))
prop.table(table(db_popfrancais$horaic))
prop.table(table(db_popimmigree$nuitc))
prop.table(table(db_popfrancais$nuitc))

# Moyenne des variables quantitatives  
summarise(group_by(db,poporigine),mean(age),mean(heures),mean(anc))

# Comparaison des caractéristiques de la population immigrée avec la population née en France

# > Interprétations (Résultats dans le tableau en annexe (fichier excel 'tableau' >> onglet 'statistiques descriptives')): 
#Elements différenciants:
# - Les attributs "sexe", "ancienneté", "couple", "nature des horaires" et "travail de nuit" sont distribués de manière relativement homogènes.
# - La population née en France est mieux préparée pour la vie active avec un niveau d'études supérieures plus élevée.
# - Prépondérance de la population née en France dans les postes hiérarchiquement plus élevés.
# - La population immigrée reste professionnellement plus longtemps active (4 annnées supplémentaires).
# - La population immigrée travail davantage de nuit 

## Test d'hypothèses des attributs entre les deux populations.
# Test d'indépendance du khi-deux (χ²) pour les variables 'sexe', diplome', 'CSP', 'horaire', 'travail de nuit' des deux populations
table_result_chitest <- CreateTableOne(data = db, vars=c("ddipl","sexe","cstotr","nuitc","couple"), strata="poporigine", test = TRUE, testExact = chisq.test)
print(table_result_chitest)

# Test de student pour les variables 'heures', 'salaire', 'age', 'couple', 'horaires' des deux populations 
table_result_ttest <- CreateTableOne(data = db, vars=c("anc","whor","salaire","age","couple","horaic"), strata="poporigine", test = TRUE, testExact = oneway.test)
print(table_result_ttest)

# > Interprétations,  on constate des différences significatives entre les deux populations concernant les variables suivantes: 'âge','ancienneté','diplôme','nombre d'heures','catégorie socio-professionnelle','horaires semblables d'une semaine à l'autre','horaires variables d'une semaine à l'autre'.

##   Modèle de regression multiple 
# Estimation de l'effet du genre sur le salaire: la variable explicatives "âge" est-elle contributive à la variable endogène "salaire" ? 
mm_sal_age <- lm(salaire~poporigine+age,data=db)
summary(mm_sal_age)
# > Interprétations: 
# - L'ordonnée à l'origine (constante) "Alpha α": les individus nés en France perçoivent un salaire moyen d'entrée de 1 276€.
# - Coefficient directeur "Beta β" (): 
#     À âge équivalent, les immigrés perçoivent un salaire mensuel moyen inférieur de 142,7€ .
#     À population équivalente, chaque date d'anniversaire des employés engendre l'augmentation du salaire annuel de 12,2€.

# Estimation de l'effet du genre sur le salaire: la variable explicative "ancienneté" est-elle contributive à la variable endogène "salaire" ? 
mm_sal_anc <- lm(salaire~poporigine+anc,data=db)
summary(mm_sal_anc)
# > Interprétations: 
# - L'ordonnée à l'origine (constante) "Alpha α": les individus nés en France perçoivent un salaire moyen d'entrée de 1 500€.
# - Coefficient directeur "Beta β" (): 
#     À ancienneté équivalente, les immigrés perçoivent un salaire mensuel moyen inférieur de 75,9€.
#     À population équivalente, l'augmentation d’une année d'ancienneté engendre une augmentation du salaire mensuel moyen de 23€.

# Estimation de l'effet du genre sur le salaire: la variable explicative "nombre d'heures" est-elle contributive à la variable endogène "salaire" ? 
db$whor <- db$salaire/db$heures
mm_sal_heure=lm(whor~poporigine+heures,data=db)
summary(mm_sal_heure)
# > Interprétations: 
# - L'ordonnée à l'origine (constante) "Alpha α": les individus nés en France perçoivent un salaire horaire moyen d'entrée de 35€.
# - Coefficient directeur "Beta β" (): 
#     À nombre d'heures travaillés égales, le salaire horaire moyen mensuel des immigrés est inférieur de 1,97€ à celui des natifs.
#     À population équivalente, chaque mois entraine l'augmentation du salaire horaire moyen de 0,36€.

# Estimation de l'effet du genre sur le salaire: la variable explicative "catégorie socio-professionnelle" est-elle contributive à la variable endogène "salaire" ? 
mm_sal_cstotr <- lm(salaire~poporigine+cstotr,data=db)
summary(mm_sal_cstotr)
# > Interprétations: 
# - L'ordonnée à l'origine (constante) "Alpha α": les individus nés en France perçoivent un salaire moyen d'entrée de 2850€.
# - Coefficient directeur "Beta β" (): 
#     À catégorie socio-professionnelle équivalente, les immigrés perçoivent un salaire mensuel moyen inférieur de 89€.
#     À population équivalente, la différence salariale entre les professions intermédiaires et les cadres s'élève à 909€.
#     À population équivalente, la différence salariale entre les employés et les cadres s'élève à 1501€.
#     À population équivalente, lla différence salariale entre les ouvriers et les cadres s'élève à 1325€.

# Estimation de l'effet du genre sur le salaire: la variable explicative "diplôme" est-elle contributive à la variable endogène "salaire" ? 
mm_sal_ddipl <- lm(salaire~poporigine+ddipl,data=db)
summary(mm_sal_ddipl)
# > Interprétations: 
# - L'ordonnée à l'origine (constante) "Alpha α": les individus nés en France perçoivent un salaire moyen d'entrée de 2370€.
# - Coefficient directeur "Beta β" (): 
#     À catégorie socio-professionnelle équivalente, les immigrés perçoivent un salaire mensuel moyen inférieur de 105€.
#     À population équivalente, la différence salariale entre les individus ayant un diplôme bac+2 et les individus ayant un diplome supérieur à bac+2 s'élève à 348€.
#     À population équivalente, la différence salariale entre les individus ayant un diplôme brevet ou bac et les individus ayant un diplome supérieur à bac+2 s'élève à 717€.
#     À population équivalente, la différence salariale entre les individus ayant un diplôme CAP ou BEP et les individus ayant un diplome supérieur à bac+2 s'élève à 765€.
#     À population équivalente, la différence salariale entre les individus ayant un diplôme brevet des collèges et les individus ayant un diplome supérieur à bac+2 s'élève à 863€.
#     À population équivalente, la différence salariale entre les individus n'aucuns diplômes et les individus ayant un diplome supérieur à bac+2 s'élève à 1029€.

# Estimation de l'effet du genre sur le salaire: la variable explicatives "horaires semblables d'une semaine à l'autre" est-elle contributive à la variable endogène "salaire" ? 
mm_sal_horaic=lm(salaire~poporigine+horaic,data=db)
summary(mm_sal_horaic)
# > Interprétations: 
# - L'ordonnée à l'origine (constante) "Alpha α": les individus nés en France perçoivent un salaire moyen d'entrée de 1 793€.
# - Coefficient directeur "Beta β" (): 
#     À horaires semblables d'une semaine à l'autre équivalentes, les immigrés perçoivent un salaire mensuel moyen inférieur de 148,7€ .

###############
# Question n°4#
###############

# Retraitement des variables.
db$ddipl <- fct_recode(db$ddipl, "7" = "6")
db$nuitc <- fct_recode(db$nuitc, "1" = "2")
db$horaic_un <- ifelse(db$horaic=="1",1,0)
db$horaic_deux <- ifelse(db$horaic=="2",1,0)
db$horaic_trois <- ifelse(db$horaic=="3",1,0)
# Transformation logarithmique de la variable à expliquer salaire afin d'induire la normalité et stabiliser la variance des résidus
db$lsalaire <- log(db$salaire)

# Estimation de l'effet simultané de toutes les variables mobilisées "toutes choses égales par ailleurs"
mm_sal_all <- lm(lsalaire~poporigine+age+sexe+couple+anc+ddipl+cstotr+heures+horaic_un+horaic_deux+horaic_trois+nuitc,data=db)
summary(mm_sal_all)
# > Interprétations:
# - "Toutes choses égales par ailleurs", à population équivalente, la population immigrée perçoit un salaire mensuel moyen inférieur de 0,82% à celui des individus nés en France, une différence de -8,3 pt contre le résultat de la question n°2.
# - "Toutes choses égales par ailleurs", à population équivalente, les femmes perçoivent un salaire mensuel moyen inférieur de 8,65% à celui des hommes.
# - "Toutes choses égales par ailleurs", à population équivalente, l'augmentation d’une année d'ancienneté engendre une augmentation de 0,94% du salaire mensuel moyen.


###############
#Question n°5 #
###############

# Transformation logarithmique de la variable à expliquer salaire afin d'induire la normalité et stabiliser la variance des résidus
db_popimmigree$lsalaire <- log(db_popimmigree$salaire)
db_popfrancais$lsalaire <- log(db_popfrancais$salaire)

# Estimation de l’équation de salaire pour la population immigrée (décomposition)
model_popim <- lm(lsalaire~age+sexe+couple+anc+ddipl+cstotr+heures+horaic+nuitc,data=db_popimmigree)
beta_popim <- coef(model_popim)
summary(model_popim)

# Calcul des parties expliquée et inexpliquée de l’écart de salaire entre la population immigrée et née en France
model_popfr <- lm(lsalaire~age+sexe+couple+anc+ddipl+cstotr+heures+horaic+nuitc,data=db_popfrancais)
beta_popfr <- coef(model_popfr)
summary(model_popfr)

var_expli_popim <- model.matrix(~age+sexe+couple+anc+ddipl+cstotr+heures+horaic+nuitc,data=db_popimmigree)
var_expli_popim_moy <- apply(var_expli_popim,2,mean)

var_expli_popfr <- model.matrix(~age+sexe+couple+anc+ddipl+cstotr+heures+horaic+nuitc,data=db_popfrancais)
var_expli_popfr_moy <- apply(var_expli_popfr,2,mean)

exp1 <- (var_expli_popfr_moy-var_expli_popim_moy)*beta_popfr
sum(exp1)
inexp1 <- (beta_popfr-beta_popim)*var_expli_popim_moy
sum(inexp1)

exp2 <- (var_expli_popfr_moy-var_expli_popim_moy)*beta_popim
sum(exp2)
inexp2 <- (beta_popfr-beta_popim)*var_expli_popfr_moy
sum(inexp2)

# > Interprétations (Résultats dans le tableau en annexe (fichier excel 'tableau' >> onglet 'décomposition')):
# Les différences de caractéristiques individuelles et d’emploi considérées expliquent l’écart de salaire moyen observé entre les individus nés en France et les individus d'origine immigrée.
# Si la population d'origine immigrée et la population native française avaient exactement les mêmes caractéristiques individuelles et d’emploi considérées, la population d'origine immigrée devraient percevoir en moyenne des salaires inférieures à la population native française : -11% selon le modèle 1 et -10,9% selon le modèle 2.
# Les individus d'origine immigrée perçoivent en moyenne des salaires supérieurs de 1% selon le modèle 1 et de 0,7% selon le modèle 2 à ceux des individus en France. 

###############
#Question n°6 #
###############

# Décomposition détaillée de l’écart de salaire entre la population immigrée et celle née en France
decompo_detaillee <- oaxaca(formula=lsalaire~age+sexe+couple+anc+ddipl+cstotr+heures+horaic+nuitc | poporigine, data=db)
decompo_detaillee$twofold$variables[[2]]
# > Interprétations (Résultats dans le tableau en annexe (fichier excel 'tableau' >> onglet 'décomposition')): 
# Contribution positive entre les individus immigrées et les individus nés en France s'explique par l'ancienneté, 29% de l'écart salarial s'explique par le fait que la population née en France a davantage d'ancienneté que la population immigrée.
# Contribution positive entre les individus immigrées et les individus nés en France s'explique par le nombre d'heures, 45% de l'écart salarial s'explique par le fait que la population née en France a un nombre d'heures travaillés plus elevé que la population immigrée.
# Contribution négative entre les individus immigrées et les individus nés en France s'explique par les diplômes de niveau 'CAP' et 'BEP', 9% de l'écart salarial ne s'explique pas par le fait que la population immigrée est davantage est davantage sous diplome que la population née en France.
