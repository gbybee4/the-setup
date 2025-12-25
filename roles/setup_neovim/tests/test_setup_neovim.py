def test_neovim_is_installed(host):
    result = host.run("nvim --version")
    assert result.rc == 0, "Neovim should be installed and executable"


def test_config_dir_is_populated(host):
    user = host.user()
    config_dir_path = f"{user.home}/.config/nvim"
    config_dir = host.file(config_dir_path)
    assert config_dir.is_directory, f"Neovim config directory {config_dir_path} should exist"
    assert config_dir.size > 0, f"Neovim config directory {config_dir_path} should not be empty"
