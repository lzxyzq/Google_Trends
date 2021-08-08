## load MARSS
library(MARSS)
library(readxl)
library(caret)
## load the data
File_name = "Fraction_PRI_DOM_2017_S1_250.csv"
dir = "../3_Result/3.3_ADF_Test/Dominican/PRI_DOM_2017_S1.csv"
ColEd <- read.csv(dir)

##Remove highly correlated keywords
ColEd_NoDate <- ColEd[,-1]
dim(ColEd_NoDate)
descrCor <-  cor(ColEd_NoDate)
highlyCorDescr <- findCorrelation(descrCor, cutoff = .90)
ColEd_NoDate2 <- ColEd_NoDate[,-highlyCorDescr]
dim(ColEd_NoDate2)
## transpose data so time goes across columns
dat_Col <- t(ColEd_NoDate[,])

## Ramdom get N rows
N = 10
df = data.frame(dat_Col)
dat_Col = df[sample(nrow(df), N), ]

## get length of time series
TT <- dim(dat_Col)[2]

##De-meaning? Check if it helps with convergence
##y_bar <- apply(dat_Col, 1, mean, na.rm = TRUE)
##dat <- dat_Col - y_bar
dat <- data.matrix(dat_Col[,])
## get number of time series
N_ts <- dim(dat)[1]

##rownames(dat) <- rownames(dat_Col)

## 'ZZ' is loadings matrix - Single factor, so m=1, for this example: 5 time series (it should be N_ts)

Z_vals <- sprintf("Z[%d]",seq(1:N_ts))

ZZ <- matrix(Z_vals, nrow = N_ts, ncol = 1, byrow = TRUE)
ZZ

## 'aa' is the offset/scaling
aa <- "zero"
## 'DD' and 'd' are for covariates
DD <- "zero"  # matrix(0,mm,1)
dd <- "zero"  # matrix(0,1,wk_last)
## 'RR' is var-cov matrix for obs errors
RR <- "diagonal and unequal"

## number of processes
mm <- 1
## 'BB' is identity: 1's along the diagonal & 0's elsewhere
BB <- "identity"  # diag(mm)
## 'uu' is a column vector of 0's
uu <- "zero"  # matrix(0, mm, 1)
## 'CC' and 'cc' are for covariates
CC <- "zero"  # matrix(0, mm, 1)
cc <- "zero"  # matrix(0, 1, wk_last)
## 'QQ' is identity
QQ <- "identity"  # diag(mm)

## list with specifications for model vectors/matrices
mod_list <- list(Z = ZZ, A = aa, D = DD, d = dd, R = RR,
                 B = BB, U = uu, C = CC, c = cc, Q = QQ)
## list with model inits
init_list <- list(x0 = matrix(rep(0, mm), mm, 1))
## list with model control parameters
con_list <- list(maxit = 3000, allow.degen = TRUE)

## fit MARSS
dfa_1 <- MARSS(y = dat, model = mod_list, inits = init_list, control = con_list)

## get the estimated ZZ
Z_est <- coef(dfa_1, type = "matrix")$Z
proc_rot <- dfa_1$states
t(proc_rot)
## Write result to CSV
a = cbind(ColEd$date,t(proc_rot))
a = data.frame(a)
names(a)[1] <- "Date"
names(a)[1] <- "Value"
write.csv(a, paste("DFM",File_name,sep="_"))


