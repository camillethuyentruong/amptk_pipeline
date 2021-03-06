# Part 7. Script for Illumina MiSeq2x300 Juniperus projects: Texcoco 
# In R this is step 4. Network presence-absence  
# January, 2021

library("phyloseq"); packageVersion("phyloseq")
library("ggplot2"); packageVersion("ggplot2")
library("vegan"); packageVersion("vegan")
library("RColorBrewer"); packageVersion("RColorBrewer")
library("plotly"); packageVersion("plotly")
library("htmltools"); packageVersion("htmltools")
library("DT"); packageVersion("DT")
library(gplots)
library(network)
library(sna)
library(pals)
library(GGally)
library(igraph)
library(bipartite)

theme_set(theme_bw())


# Set working directory to source file


source("../bin/4_Filter_otu_table.R")

#### Subset by project ####

# Use binary table where OTUs present in only one sample were removed

subset.texcoco.binary.beta <- subset_samples(binary_table_OTU2, Project %in% "Texcoco")
subset.texcoco.binary.beta
sample_data(subset.texcoco.binary.beta)

# Remove OTUs that are not present in any of the samples of the subset
any(taxa_sums(subset.texcoco.binary.beta) == 0)
taxa_sums(subset.texcoco.binary.beta) [1:10]

subset.texcoco.binary.beta <- prune_taxa(taxa_sums(subset.texcoco.binary.beta) > 0, subset.texcoco.binary.beta)

any(taxa_sums(subset.texcoco.binary.beta) == 0)
taxa_sums(subset.texcoco.binary.beta) [1:10]
subset.texcoco.binary.beta


#### Network using sna #### 

# Select data
subset <- subset_taxa(subset.texcoco.binary.beta, Trophic %in% c("a__ecm"))
subset<- subset_samples(subset, Type %in% "root")
subset

# Remove taxa not present in subset
any(taxa_sums(subset) == 0)
subset <- prune_taxa(taxa_sums(subset) > 0, subset)
subset

# Verify what is there
tax_table(subset)
otu_table(subset)

## Obtain dataframe with presence/absence data for each OTU in each plant host ## 

# Merge by category 
nw <-merge_samples(subset, group = "Host")
network_host <- as.data.frame(otu_table(nw))

# vectors
taxa_names(tax_table(subset))
color<-as.matrix(tax_table(subset))
color<-as.data.frame(color)

# Check how it looks with gplot
gplot(network_host, thresh = 0.2, displaylabels = TRUE, vertex.col = color$Family)
network_host

# Merge more than one category

sample_variables(subset)

variable1 = as.character(get_variable(subset, "Host"))
variable2 = as.character(get_variable(subset, "Site"))

sample_data(subset)$NewPastedVar <- mapply(paste0, variable1, variable2, 
                                           collapse = "_")
nw2<- merge_samples(subset, "NewPastedVar")

# Create dataframe with presence/absence data for each OTU in each category  
network_host <- as.data.frame(otu_table(nw2))

# Turn it because we need hosts (nodes) as columns 
network_host<-t(network_host)

# Take out to excel the taxonomy information that we are goint to use later on for plotting 
nuevoedge<-write.csv(color, file = "nuevoedge_df.csv")

# Read file 
nuevoedge<-read.csv("nuevoedge_df.csv")

head(nuevoedge)
head(network_host)

# Check what is there 
nuevoedge # we need the id as a column, i.e. OTUname as the first column followed by the taxonomy 


#Now using Gplot instead, color by Family 
gplot(network_host, thresh = 0.2, displaylabels = TRUE, usearrows=FALSE, 
      legend(x=1,y=-1, pch=21, col = "#777777", 
             pt.cex=2, cex=.8, bty="n", ncol=1), vertex.col = nuevoedge$Family)


gplot(network_host, thresh = 0.2, displaylabels = TRUE, usearrows=FALSE, 
      legend(x=1,y=-1, color, pch=21,  
             pt.cex=2, cex=.8, bty="n", ncol=1), vertex.col = nuevoedge$Family)

# Make another plot with nicer colors and nodes 

# call color palette
pal2 <-polychrome(27)

# so it does not plot on the same page 
par(mfrow=c(1,2), xpd=T)

gplot(as.one.mode(network_host),
      displaylabels = TRUE,
      gmode="graph",
      label.cex=1, vertex.col = nuevoedge$Family, vertex.cex=1)

par(mfrow=c(1,2), xpd=T)

palette(polychrome(n=27))
gplot(network_host, gmode="graph", jitter=FALSE,
      displaylabels = TRUE,
      boxed.labels=FALSE, label.pos=1, label.cex=1, vertex.cex=1,
      vertex.col= nuevoedge$Family)

par(mfrow=c(1,2), xpd=T)

# Plot with no labels 
gplot(network_host, gmode="graph", jitter=FALSE,
      displaylabels = FALSE,
      boxed.labels=FALSE, label.pos=1, label.cex=1, vertex.cex=2,
      vertex.col= nuevoedge$Family)

par(mfrow=c(1,2), xpd=T)

gplot(network_host, gmode="graph", jitter=FALSE,
      label = nuevoedge$Family,
      boxed.labels=FALSE, label.pos=1, label.cex=1, vertex.cex=1,
      vertex.col= nuevoedge$Family)

# Another option is to use ggnet, plot looks nicer but not sure how to add color  

net = network(otu_table(subset), directed = FALSE)
ggnet2(net, node.size = 3, edge.size = 1, node.color = 'mode', edge.color = "grey", label = TRUE)

#or

network_host<-t(network_host)
network_host<-as.data.frame(network_host, stringsAsFactors = F)
network_host[, 2] <- as.character(network_host[, 2])
net = network(network_host, directed = FALSE)
ggnet2(net, node.size = 3, edge.size = 1, node.color = "mode", edge.color = "grey", label = TRUE)

#### Networks using igraph ####

# Unfinished part

# Merge more than one category

sample_variables(subset)

variable1 = as.character(get_variable(subset, "Host"))
variable2 = as.character(get_variable(subset, "Site"))

sample_data(subset)$NewPastedVar <- mapply(paste0, variable1, variable2, 
                                           collapse = "_")
nw2<- merge_samples(subset, "NewPastedVar")

# Create dataframe with presence/absence data for each OTU in each category  
network_host <- as.data.frame(otu_table(nw2))


#Other format
abc<-t(network_host)

#Plot
plotweb(network_host)

#Plot
visweb(network_host)

network_host

head(tax_table(subset))

otu.c <- t(otu_table(subset)@.Data) #extract the otu table from phyloseq object
tax.c <- as.data.frame(tax_table(subset)@.Data)#extract the taxonomy information






#### Frequence in each plant host table ####

# In order to further analyze presence/absence of otus in each plant host, 
# you can create a frequency table for the fungal category you wish: 

#Make the subset
subset.myc <- subset_taxa(subset.texcoco.binary.beta, Trophic %in% c("a__am"))
subset.myc <- subset_samples(subset.myc, Type %in% c("root"))
subset.myc

any(taxa_sums(subset.myc) == 0)
subset.myc <- prune_taxa(taxa_sums(subset.myc) > 0, subset.myc)
subset.myc

tax_table(subset.myc)
otu_table(subset.myc)
sample_data(subset.myc)

# Make a dataframe with OTUs as column and samples as rows
predictors <- t(otu_table(subset.myc))
dim(predictors)
predictors <- as.table(predictors)
predictors<- as.data.frame(predictors)
dim(predictors)

Host <- as.factor(sample_data(subset.myc)$Host) # variables
Site <- as.factor(sample_data(subset.myc)$Site) # variable

predictors <- data.frame(predictors,Host,Site) #this is the dataframe 
head(predictors)

predictors$HS <- paste0(predictors$Host, predictors$Site) # now add the variables 

tax.table<-as.data.frame(tax_table(subset.myc))
tax.table
match.id <- match(predictors$Var2, rownames(tax.table)) # now add the taxonomy 

predictors$Family <- tax.table$Family[match.id] # add the taxonomic levels you wish 
predictors$Trophic <- tax.table$Trophic[match.id]
predictors$Genus <- tax.table$Genus[match.id] 

predictors <- subset(predictors, predictors$Freq == 1) # now get the frequence 

sort(table(predictors$Var2))

sharedotusam<-write.csv(predictors, file = "sharedotusacm.csv") # you can take it to excel for further observations