#!"C:/xampp/perl/bin/perl.exe"
use CGI::Carp 'fatalsToBrowser';
use Encode qw(decode);
use CGI;

my $cgi = CGI->new;

my $nombre = decode('UTF-8', $cgi->param('nombreU'));
my $periodo = $cgi->param('periodoL');
my $departamento = decode('UTF-8', $cgi->param('departamentoL'));
my $denominacion = decode('UTF-8', $cgi->param('denominacionP'));

my $archivo;
my $aja;
open($archivo, "Programas_de_Universidades.csv");


while (my $line = <$archivo>) {
    my @campos = $line =~ /([^|]+)/g;
    if ($campos[1] eq $nombre && $campos[4] eq $periodo && $campos[10] eq $departamento && $campos[16] eq $denominacion) {
        $aja = $line."<br>";
        #print $line."<br>";
    }
}

close($archivo);
open(my $resultadosHTML, "../htdocs/Resultados.html");

my @resultadosHTML = <$resultadosHTML>;
close $resultadosHTML;

for (my $i = 0; $i < @resultadosHTML; $i++){
    if ($resultadosHTML[$i] =~ /<table>/) {
        splice(@resultadosHTML, $i+1, 0, "<tr><td>$aja<td><tr>");
    }
}

open my $resultadosHTML, '>:utf8', '../htdocs/Resultados.html';
print $resultadosHTML @resultadosHTML;
close $resultadosHTML;

print $cgi->redirect('http://localhost/Resultados.html');