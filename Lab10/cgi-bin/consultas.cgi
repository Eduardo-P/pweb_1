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

print "Content-Type: text/html\n\n";
while (my $line = <$archivo>) {
    my @campos = $line =~ /([^|]+)/g;
    if ($campos[1] eq $nombre && $campos[4] eq $periodo && $campos[10] eq $departamento && $campos[16] eq $denominacion) {
        print $line."<br>";
    }
}

close($archivo);