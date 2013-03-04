package test::wxdownload; 
#-----------------------------------------------------------------------------# 
#     Version: 1.0 
#    
# Web Address: http://bryantmcgill.com 
#   Use Terms: Free for non-commercial use, commercial use with notification. 
# 
#       Legal: This code is provided "as is" without warranty of any kind. 
#              The entire risk of use remains with the recipient.  
#              In no event shall Bryant McGill be liable for any direct, 
#              consequential, incidental, special, punitive or other damages. 
#-----------------------------------------------------------------------------# 
sub wx_download_file_with_progress_dialog { 
  my ($url, $parent, $title, $message, $modal, $lwp_agent) = @_; 
  use Wx ':everything'; 
  use LWP; 
  $lwp_agent = LWP::UserAgent->new() unless (ref $lwp_agent eq 'LWP::UserAgent'); 
  my $result = $lwp_agent->head($url); 
  my $remote_headers = $result->headers; 
  my $update_size = $remote_headers->content_length; 
  my $flags = wxPD_ELAPSED_TIME | wxPD_ESTIMATED_TIME | wxPD_REMAINING_TIME | wxPD_AUTO_HIDE | wxPD_CAN_ABORT; 
  $flags = $flags | wxPD_APP_MODAL if ($modal ne 'false'); 
  my $progress_dialog = Wx::ProgressDialog->new($title, $message, $update_size, $parent, $flags); 
  $progress_dialog->Show(1); 
  my $download_data = ''; 
  my $aborted = 0; 
  my $file_data = $lwp_agent->get($url, ':content_cb' => \&wx_download_file_with_progress_dialog_update_progress ); 
  $file_data = $file_data->content(); 
  $progress_dialog->Destroy(); 
  return (length $file_data > length $download_data) ? $file_data : $download_data; 
  #return $download_data; 
  sub wx_download_file_with_progress_dialog_update_progress { 
    my ($data, $response, $protocol) = @_; 
    $download_data .= $data; 
    my $continue = $progress_dialog->Update(length $download_data); 
    if (!$continue) { 
      $aborted = 1; 
      $lwp_agent->abort; 
    } 
  } 
} 
1;