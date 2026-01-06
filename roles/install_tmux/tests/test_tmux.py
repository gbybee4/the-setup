def test_tmux_is_installed(host):
    result = host.run("tmux -V")
    assert result.rc == 0, "tmux should be installed and executable"


def test_config_is_populated(host):
    user = host.user()
    config_path = f"{user.home}/.tmux.conf"
    config_file = host.file(config_path)
    assert config_file.exists, f"tmux config file {config_path} should exist"


def test_tpm_is_installed(host):
    user = host.user()
    tpm_path = f"{user.home}/.tmux/plugins/tpm"
    tpm_dir = host.file(tpm_path)
    assert tpm_dir.exists, f"tmux plugin manager should be installed at {tpm_path}"
