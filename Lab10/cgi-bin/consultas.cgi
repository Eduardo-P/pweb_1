#!"C:/xampp/perl/bin/perl.exe"
use strict;
use warnings;
use CGI;

my $cgi = CGI->new;

my $nombre = $cgi->param('nombreU');
my $periodo = $cgi->param('periodoL');
my $departamento = $cgi->param('departamentoL');
my $denominacion = $cgi->param('denominacionP');

my $archivo;
open($archivo, "Programas_de_Universidades.csv");
my @archivoCSV = <$archivo>;
close($archivo);