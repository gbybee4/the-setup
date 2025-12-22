import yaml


def load_role_defaults():
    with open("../../roles/install_fonts/defaults/main.yaml", "r") as f:
        return yaml.safe_load(f)


def test_nerd_font_is_installed(host):
    font = load_role_defaults().get("install_fonts_nerd_font", None)
    assert font, "Font should be set"

    installed_fonts_list = host.check_output(f"fc-list :family={font}NerdFont")
    assert installed_fonts_list, "Nerd font should be installed"
