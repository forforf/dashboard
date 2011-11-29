require 'psych'

ignore /\/_.*/

module Dashboard
  class << self; attr_accessor :config; end
end

helpers do
  def load_config
    current_dir = File.dirname(__FILE__)
    config_file = File.join(current_dir, 'config.yml')
    Dashboard.config = Psych.load_file(config_file)
  end

  def latest_data
    Dashboard.config['latest']
  end

  def panels_list
    Dashboard.config['panels']
  end

  def panel_data(panel_id)
    panels_list[panel_id]
  end
end

before 'index.html.erb' do
  load_config
  @latest_id = latest_data['id']
  @panels_list_data = panels_list
  @panels_show = render('/_layouts/panels.html')
end
