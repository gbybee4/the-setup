def test_tmux_is_installed(host):
    result = host.run("tmux -V")
    assert result.rc == 0, "tmux should be installed and executable"


def test_config_is_populated(host):
    user = host.user()
    config_path = f"{user.home}/.tmux.conf"
    config_file = host.file(config_path)
    assert config_file.exists, f"tmux config file {config_path} should exist"
