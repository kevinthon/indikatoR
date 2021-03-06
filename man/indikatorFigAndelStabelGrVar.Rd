% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/indikatorFigAndelStabelGrVar.R
\name{indikatorFigAndelStabelGrVar}
\alias{indikatorFigAndelStabelGrVar}
\title{Plot andeler/rater i stabelplot}
\usage{
indikatorFigAndelStabelGrVar(Andeler, outfile, tittel, skriftStr = 1.3,
  width = 600, height = 600, sideTxt = "Boomr�de/opptaksomr�de",
  terskel = 30, decreasing = T)
}
\arguments{
\item{Andeler}{En dataramme med rater/andeler i spesifisert form}

\item{outfile}{Angir filnavn og format på figuren som returneres}

\item{tittel}{tittel på figuren}
}
\value{
Et plot av rater over tre år
}
\description{
Denne funksjonen tar som input en dataramme med andeler av tre kategorier
som til sammen summerer til 100%
}

