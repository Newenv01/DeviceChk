use chilkat();
use File::Find;
use File::Basename;

$obj = chilkat::CkJsonObject->new();
$JPath = "/var/log/s3/";

$rest = chilkat::CkRest->new();
$socket = chilkat::CkSocket->new();

#Set the SOCKS proxy domain or IP address, Port, Version
$socket->put_SocksHostname("192.168.2.10");
$socket->put_SocksPort(1080);
$socket->put_SocksVersion(5);

#Connect through the HTTP proxy to the Amazon AWS server for the S3 service.
#1. Scrape the metrics for every configured time itervel(default shall be 5 seconds)
$bTls = 1;
$port = 443;
$maxWaitMs = 300;
$success = $socket->Connect("s3.amazonaws.com",$port,$bTls,$maxWaitMs);
if ($success != 1) {
    print "Connect Failure Error Code: " . $socket->get_ConnectFailReason() . "\r\n";
    print $socket->lastErrorText() . "\r\n";
    exit;
}

#  Use the proxied TLS connection:
$success = $rest->UseConnection($socket,1);
if ($success != 1) {
    print $rest->lastErrorText() . "\r\n";
    exit;
}

#  Provide AWS credentials for the REST call.
$authAws = chilkat::CkAuthAws->new();
$authAws->put_AccessKey("AWS_ACCESS_KEY");
$authAws->put_SecretKey("AWS_SECRET_KEY");
$authAws->put_ServiceName("s3");
$success = $rest->SetAuthAws($authAws);

#  List all buckets for the account...
$responseJSON = $rest->fullRequestNoBody("GET","/");
if ($rest->get_LastMethodSuccess() != 1) {
    print $rest->lastErrorText() . "\r\n";
    exit;
}
else
{
#### 2. Store the data in a file system
$status = $responseJSON->WriteFile($JPath);
}

#3. Purge the data points older than 10 days
opendir(JDIR, $JPath ) || die "Error in opening dir $JDIRh\n";
while( ($_ = readdir(JDIR)))
{
   print("File Name $_\n");

   $full_name = canonpath $File::Find::name;
   if (-f)
   {
     $age  = int(-M);
     if ($age >= 10)
     { 
         print "Age: $age days - $full_name\n";
         unlink;
    }
  }      
}
closedir(JDIR);

#4 Expose an endpoint to query the historical data of the devices
open(JFile,"<$JPath");
while($_=<JFile>)
{
   chomp($_);
   if ( -f $_ )
   {
         $IP = system("curl http://192.168.2.10/Device.json | jq \'.[] | .ip\' $_");
         $METX = system("curl http://192.168.2.10/Device.json | jq \'map(has(\"metrics\"))\' $_");
)
close(JFile);
