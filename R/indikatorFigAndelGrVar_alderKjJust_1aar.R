#' Plot alder og kjønnsjusterte andeler/andeler i angitt format
#'
#' Denne funksjonen tar som input en dataramme med andeler over 3 år,
#' der radnavn angir grupperingsvariabel og kolonnenavn år. Funksjonen
#' returnerer et søyleplot hvor søylene representerer sist år, fyllt sirkel er året
#' før og åpen sirkel to år før
#'
#' @param andeler En dataramme med andeler/andeler i spesifisert form
#' @param outfile Angir filnavn og format på figuren som returneres,
#' @param N En vektor/matrise med N for ratene
#' @return Et plot av andeler over tre år
#'
#' @export
#'
indikatorFigAndelGrVar_aldKjJust_1aar <-
        function(Antall, outfile, tittel, width=800, height=700, minstekravTxt='Moderat', maalTxt='Høy',
                                           decreasing=F, terskel=30, minstekrav = NA, sideTxt ='Boområde/opptaksområde',
                                           maal = NA, til100=FALSE)
  {

  vekt <- tapply(Antall$N[which(Antall$aar==2015)], Antall$AldKjGr[which(Antall$aar==2015)], sum)
  vekt <- vekt/sum(vekt)

  N <- aggregate(Antall[, c('N')], by=list(aar=Antall$aar, bohf=Antall$bohf), sum)
  N <- tidyr::spread(N, 'aar', 'x')

  aux <- aggregate(Antall[, c('Antall', 'N')], by=list(aar=Antall$aar, bohf=Antall$bohf, AldKjGr=Antall$AldKjGr), sum)

  vektFrame <- data.frame('AldKjGr'=sort(unique(Antall$AldKjGr)), 'vekt'=vekt)

  tmp <-merge(aux, vektFrame, by='AldKjGr', all.x=T)
  tmp$andel_ujust <- tmp$Antall/tmp$N
  tmp$andel_just <- tmp$andel_ujust * tmp$vekt

  andeler <- aggregate(tmp[, c('andel_just')], by=list(aar=tmp$aar, bohf=tmp$bohf), sum)

  andeler <- tidyr::spread(andeler, 'aar', 'x')
  # rownames(andeler) <- as.character(andeler$bohf)
  andeler[ , 2] <- andeler[, 2]*100
  andeler[N[, 2] < terskel, 2] <- NA

  if (decreasing){
    rekkefolge <- order(andeler[, dim(andeler)[2]], decreasing = decreasing)
  } else {
    rekkefolge <- order(andeler[, dim(andeler)[2]], decreasing = decreasing, na.last = F)
  }
  andeler <- andeler[rekkefolge, ]
  N <- N[rekkefolge, ]
  andeler[N[, dim(andeler)[2]]<terskel, -dim(andeler)[2]] <- NA
  pst_txt <- paste0(sprintf('%.0f', andeler[, dim(andeler)[2]]), ' %')
  pst_txt[is.na(andeler[, dim(andeler)[2]])] <- paste0('N<', terskel, ' siste år')

  FigTypUt <- rapbase::figtype(outfile='', width=width, height=height, pointsizePDF=11, fargepalett='BlaaOff')
  farger <- FigTypUt$farger
  soyleFarger <- rep(farger[3], length(andeler[,dim(andeler)[2]]))
  soyleFarger[which(andeler[,1]=='Norge')] <- farger[4]
  # if (outfile == '') {windows(width = width, height = height)}
  windows(width = width, height = height)

  oldpar_mar <- par()$mar
  oldpar_fig <- par()$fig
  oldpar_oma <- par()$oma

  cexgr <- 1

  if (til100) {xmax <- 100
  } else {
    # xmax <- max(andeler[,-1], na.rm = T)*1.1
    xmax <- ceiling(max(c(1.05*maal, andeler[,-1]), na.rm = TRUE)/10)*10
  }

  vmarg <- max(0, strwidth(andeler[,1], units='figure', cex=cexgr)*0.8)
  par('fig'=c(vmarg, 1, 0, 1))
  par('mar'=c(5.1, 4.1, 4.1, 4.1))
  par('oma'=c(0,2,0,0))

  ypos <- barplot( t(andeler[,dim(andeler)[2]]), beside=T, las=1,
                   main = tittel, font.main=1, cex.main=1.3,
                   xlim=c(0,xmax),
                   names.arg=rep('',dim(andeler)[1]),
                   horiz=T, axes=F, space=c(0,0.3),
                   col=soyleFarger, border=NA, xlab = 'Andel (%)') # '#96BBE7'
  ypos <- as.vector(ypos)
  if (!is.na(minstekrav)) {
    lines(x=rep(minstekrav, 2), y=c(-1, max(ypos)+diff(ypos)[1]), col=farger[2], lwd=2)
    barplot( t(andeler[,dim(andeler)[2]]), beside=T, las=1,
          #   main = tittel, font.main=1, cex.main=1.3,
          #   xlim=c(0,xmax),
             names.arg=rep('',dim(andeler)[1]),
             horiz=T, axes=F, space=c(0,0.3),
             col=soyleFarger, border=NA, xlab = 'Andel (%)', add=TRUE)
    par(xpd=TRUE)
    # text(x=minstekrav, y=max(ypos)+diff(ypos)[1], labels = paste0('Min=',minstekrav,'%'), pos = 3, cex=0.7)
    text(x=minstekrav, y=max(ypos)+diff(ypos)[1], labels = minstekravTxt, #paste0(minstekravTxt, minstekrav,'%'),
         pos = 3, cex=0.9)
    par(xpd=FALSE)
  }
  if (!is.na(maal)) {
    lines(x=rep(maal, 2), y=c(-1, max(ypos)+diff(ypos)[1]), col=farger[2], lwd=2)
    barplot( t(andeler[,dim(andeler)[2]]), beside=T, las=1,
           #  main = tittel, font.main=1, cex.main=1.3,
            # xlim=c(0,xmax),
             names.arg=rep('',dim(andeler)[1]),
             horiz=T, axes=F, space=c(0,0.3),
             col=soyleFarger, border=NA, xlab = 'Andel (%)', add=TRUE)
    par(xpd=TRUE)
    # text(x=maal, y=max(ypos)+diff(ypos)[1], labels = paste0('Mål=',maal,'%'), pos = 3, cex=0.7)
    text(x=maal, y=max(ypos)+diff(ypos)[1], labels = maalTxt, #paste0(maalTxt,maal,'%'),
         pos = 3, cex=0.9)
    par(xpd=FALSE)
  }
  axis(1,cex.axis=0.9)
  mtext( andeler[,1], side=2, line=0.2, las=1, at=ypos, col=1, cex=cexgr)
  mtext( c(N[,2], 'N'), side=4, line=3.0, las=1, at=c(ypos, max(ypos)+diff(ypos)[1]), col=1, cex=cexgr, adj = 1)
  text(x=0, y=ypos, labels = pst_txt, cex=0.8, pos=4)
  # mtext( 'Boområde', side=2, line=9.5, las=0, col=1, cex=cexgr)
  mtext(sideTxt, WEST<-2, line=0.4, cex=cexgr, col="black", outer=TRUE)

  par('mar'= oldpar_mar)
  par('fig'= oldpar_fig)
  par('oma'= oldpar_oma)

  if (outfile != '') {savePlot(outfile, type=substr(outfile, nchar(outfile)-2, nchar(outfile)))}

}
