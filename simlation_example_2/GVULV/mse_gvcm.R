library(MASS)
#path <- paste0("/home/LiuJX/gvcmsim/ex2gvcm_vs_zhang.Rdata")
#load(path) 
#########true parameter##########
data_plot <- function(N){
#########################
name <-  paste0("N.", N)
est_data <- List.Kern[[name]]$result1
beta.1.mise <-mean(apply(est_data[,,'beta1']- est_data[,,'beta1_true'],1,function(x) sum(x^2/length(which(!is.na(x))),na.rm=T)),is.na = T) 
beta.2.mise <-mean(apply(est_data[,,'beta2']- est_data[,,'beta2_true'],1,function(x) sum(x^2/length(which(!is.na(x))),na.rm =T)),is.na = T) 
g.mise <-mean(apply(est_data[,,'g']- est_data[,,'g_true'],1,function(x) sum(x^2/length(which(!is.na(x))),na.rm=T)),is.na = T) 
Variance.mise <-mean(apply(est_data[,,'Variance']- est_data[,,'Variance_true'],1,function(x) sum(x^2/length(which(!is.na(x))),na.rm=T)),is.na = T) 
if(case==4){ 
  MISE <-  data.frame(beta.1.mise,beta.2.mise,g.mise,Variance.mise)
} else{
  MISE <-  data.frame(beta.1.mise,beta.2.mise,g.mise,Variance.mise,accuracy = mean(est_data[,,'predict_accuracy']))
} 
MISE <- round(MISE,digits=4)
name_1 <- paste0('gvcm_ex2_case',case,'_size',N,'.csv')
#write.csv(MISE,file=name_1,row.names=FALSE)
###################plot####################
set.seed(1)
U<-runif(N,0,1)
dp1<-seq(0,1,1/Points)
#####estimate true beta function#######
###fix dense point u############
fdp<-seq(0,1,1/(N-1));beta.1=sin(pi*fdp);beta.2=cos(pi*fdp)
bbeta=matrix(cbind(beta.1,beta.2),N,P)
Ident=sqrt(sum(bbeta[which.min(abs(fdp-mean(fdp))),1:P]^2));for(i in 1:N){bbeta[i,]=sign(bbeta[i,1])*bbeta[i,]/Ident}
beta.true.1=approx(fdp,bbeta[,1],xout=dp1,rule=2:1)$y
beta.true.2=approx(fdp,bbeta[,2],xout=dp1,rule=2:1)$y
x<-mvrnorm(N, rep(0, P), Sigma);bbeta=matrix(cbind(sin(pi*U),cos(pi*U)),N,P);Xbeta=rowSums(x*bbeta)
dp2<-seq(quantile(Xbeta,probs = 0.05),quantile(Xbeta,probs = 0.95),diff(c(quantile(Xbeta,probs = 0.05),quantile(Xbeta,probs = 0.95)))/Points); g.true = linkFun(dp2,case)[[1]]
dp3<-seq(quantile(g,probs = 0.15),quantile(g,probs = 0.85),diff(c(quantile(g,probs = 0.15),quantile(g,probs = 0.85)))/Points)
Variance.true <- dp3*(1-dp3)
#########################
est_data <- List.Kern[[name]]$result.fix
beta.1.mean = apply(est_data[,,'beta.1.fix'],2, function(x) mean(x,na.rm= T))
beta.2.mean = apply(est_data[,,'beta.2.fix'],2, function(x) mean(x,na.rm= T))
beta.1.sd = apply(est_data[,,'beta.1.fix'],2, function(x) sd(x,na.rm= T))
beta.2.sd = apply(est_data[,,'beta.2.fix'],2, function(x) sd(x,na.rm= T))
g.mean = apply(est_data[,,'g.fix'],2, function(x) mean(x,na.rm= T))
Variance.mean = apply(est_data[,,'Variance.fix'],2, function(x) mean(x,na.rm= T))

g.sd = apply(est_data[,,'g.fix'],2, function(x) sd(x,na.rm= T))
Variance.sd = apply(est_data[,,'Variance.fix'],2, function(x) sd(x,na.rm= T))

beta.1.upper = beta.1.mean+1.96*beta.1.sd
beta.2.upper = beta.2.mean+1.96*beta.2.sd
g.upper = g.mean+1.96*g.sd;Variance.upper = Variance.mean+1.96*Variance.sd;

beta.1.lower = beta.1.mean-1.96*beta.1.sd; beta.2.lower = beta.2.mean-1.96*beta.2.sd
g.lower = g.mean-1.96*g.sd; Variance.lower = Variance.mean-1.96*Variance.sd
beta1.plot.data <- data.frame(dp1 = dp1, beta.1.mean = beta.1.mean, beta.1.upper = beta.1.upper,beta.1.lower = beta.1.lower,beta.true.1 = beta.true.1)
beta2.plot.data <- data.frame(dp1 = dp1, beta.2.mean = beta.2.mean, beta.2.upper = beta.2.upper,beta.2.lower = beta.2.lower,beta.true.2= beta.true.2)
g.plot.data <- data.frame(dp2 = dp2, g.mean = g.mean, g.upper = g.upper, g.lower = g.lower,g.true = g.true)
Variance.plot.data <- data.frame(dp3 = dp3, Variance.mean = Variance.mean, Variance.upper = Variance.upper, Variance.lower = Variance.lower,Variance.true = Variance.true)
source('plot_ex2_case4.R',local=TRUE)	
a <- grid.arrange(beta1.plot,beta2.plot,g.plot,V.plot,nrow = 1)
#b<- grid.arrange(V.plot,nrow = 1)
name2 <-  paste0("gvcm_ex2_case_dh",case,":number_",N,".png")
ggsave(name2,plot = a,width = 16, height = 3)
#ggsave("gvcm_ex2_variance.png",plot = b,width = 4, height = 3)
print(MISE)
}
N = 800
while(N < 2001){
if(N==2000){resulting <- data_plot(N);N=N+10}
if(N==1500){resulting <-data_plot(N);N=N+500}
if(N==1100){resulting <-data_plot(N);N=N+400}
if(N==800){resulting <-data_plot(N);N=N+300} 
}
