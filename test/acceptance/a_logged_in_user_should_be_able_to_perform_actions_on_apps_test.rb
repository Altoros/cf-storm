scope do

  setup do
    login_user!
    load_default_space_and_app
  end

  test 'Given Im seeing apps in development space then I should be able
       to stop an app' do

    click_on "stop-#{@app.name}"
    assert find("#start-#{@app.name}")
  end
end