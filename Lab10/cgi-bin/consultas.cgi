#!"C:/xampp/perl/bin/perl.exe"
use Encode qw(decode);
use CGI;

my $cgi = CGI->new;

my $nombre = decode('UTF-8', $cgi->param('nombreU'));
my $periodo = $cgi->param('periodoL');
my $departamento = decode('UTF-8', $cgi->param('departamentoL'));
my $denominacion = decode('UTF-8', $cgi->param('denominacionP'));

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