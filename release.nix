{
  pname, version, src, mixRelease, fetchMixDeps, elixir
}:
{
  default = mixRelease {
    inherit pname version src elixir;
    # stripDebug = true;
    mixFodDeps = fetchMixDeps {
      pname = "mix-deps-${pname}";
      inherit src version elixir;
      sha256 = "sha256-rwWGs4fGeuyV6BBFgCyyDwKf/YLgs1wY0xnHYy8iioE=";
    };

    # Even you set RELEASE_COOKIE on your own, env.sh is still loaded and causes
    # an error. Thus you need to set cookie_path to a writable directory.
    postInstall = ''
      substituteInPlace $out/releases/${version}/env.sh \
        --replace '"''${RELEASE_ROOT}/releases/COOKIE"' '"/dev/null"'
    '';
  };
}
