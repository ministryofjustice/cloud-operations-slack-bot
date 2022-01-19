class SlackController < ApplicationController
  def events
    if params[:slack][:type] == "app_mention"
      render plain: "Authentication successful"
     
    else
      render plain: "Hello World"
    end  
  end
end

# describe DhcpConfigParser do
#   let(:kea_config_json) { File.read("./spec/lib/data/kea.json") }
#   let(:legacy_config_filepath) { "./spec/lib/data/export.txt" }
#   let(:subnet_list) { ["192.168.1.0", "192.168.2.0"] }
#   let(:fits_id) { "FITS_1646" }

#   {
#   "Dhcp4": {
#     "interfaces-config": {
#       "interfaces": [
#         "*"
#       ],
#       "dhcp-socket-type": "udp",
#       "outbound-interface": "use-routing"
#     },
#     "lease-database": {
#       "type": "mysql",
#       "name": "<DB_NAME>",
#       "user": "<DB_USER>",
#       "password": "<DB_PASS>",
#       "host": "<DB_HOST>",
#       "port": 3306
#     },

#     ....
