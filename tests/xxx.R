library(SASxport)
Sys.setenv("TZ"="GMT")

## manually create a data set
abc <- data.frame( x=c(1, 2, NA, NA ), y=c('a', 'B', NA, '*' ) )

## add a format specifier (not used by R)
SASformat(abc$x) <- 'date7.'

## add a variable label (not used by R)
label(abc$y)  <- 'character variable'

## create a SAS XPORT file from our local data frame
write.xport(abc,
            file="xxx2.xpt",
            cDate=strptime("28JUL07:21:08:06 ", format="%d%b%y:%H:%M:%S"),
            osType="SunOS",
            sasVer="9.1",
            autogen.formats=FALSE
            )

# display for diff
write.xport(abc,
            file="",
            cDate=strptime("28JUL07:21:08:06 ", format="%d%b%y:%H:%M:%S"),
            osType="SunOS",
            sasVer="9.1",
            autogen.formats=FALSE,
            verbose=TRUE
            )


## read the original SAS data file
abc.SAS <- read.xport("xxx.xpt", names.tolower=FALSE)

## read.xport currently doesn't properly load the format attribute *length*...
##SASformat(abc.SAS$X) <- 'date7.'

## create a SAS XPORT file from the SAS data
write.xport(abc=abc.SAS,
            file="xxx3.xpt",
            cDate=strptime("28JUL07:21:08:06 ", format="%d%b%y:%H:%M:%S"),
            osType="SunOS",
            sasVer="9.1",
            autogen.formats=FALSE
            )


## display for diff
write.xport(abc=abc.SAS,
            file="",
            cDate=strptime("28JUL07:21:08:06 ", format="%d%b%y:%H:%M:%S"),
            osType="SunOS",
            sasVer="9.1",
            autogen.formats=FALSE,
            verbose=TRUE
            )


## Load both files back in as raw data
a.1 <- readBin( con="xxx.xpt",  what=raw(), n=1e5 )
a.2 <- readBin( con="xxx2.xpt", what=raw(), n=1e5 )
a.3 <- readBin( con="xxx3.xpt", what=raw(), n=1e5 )

## R doesn't have multiple NA types, while SAS does.  The original
## file contains a SAS '.A' missing value, while what we've created
## contains an ordinary '.' missing value, so mash this one byte to
## avoid a comparison error for this known limitation.

a.1[1089] <- as.raw("0x2e")

## Test that the files are otherwise identical
stopifnot( all(a.1 == a.2) )
stopifnot( all(a.1 == a.3) )


