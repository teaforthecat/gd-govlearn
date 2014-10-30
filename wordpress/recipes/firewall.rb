# open standard ssh port, enable firewall
firewall_rule 'ssh' do
  port     22
  action   :allow
  notifies :enable, 'firewall[ufw]'
end

firewall_rule 'http/https' do
  protocol :tcp
  ports    [80, 443]
  action   :allow
end
