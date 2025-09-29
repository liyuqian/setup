library collection;

export 'src/setup.dart'
    show
        home,
        isShellBash,
        isShellZsh,
        rcFilePath,
        kRawGithubRoot,
        Cmd,
        Check,
        CheckByCmd,
        CheckCmdExistence,
        FileCheck,
        Setup,
        SetupByCmds,
        ConfigFileSetup,
        AptInstall,
        SnapInstall,
        BrewInstall,
        GetOmzPlugin,
        DownloadFile,
        setUpMultiple;

export 'src/shared.dart'
    show
        makeGitSetup,
        setUpPdm,
        VimPlugin,
        protocPluginSetup,
        installBun,
        installFirebase,
        ohMyTmux,
        ultimateVimrc,
        dartVimPlugin,
        ctrlpVimPlugin,
        fzfPlugin,
        fzfVimPlugin,
        cocVimPlugin;

export 'src/zsh.dart'
    show
        setUpZshUbuntu,
        setUpZshMac,
        setUpZsh,
        cloneFzf,
        installFzf,
        ohMyZsh,
        powerLevel10k,
        setZshAsDefault,
        setVimInZshrc;

export 'src/dotfile.dart' show kRelativePathToHash, downloadDotfiles;

export 'src/default.dart' show defaultLogger;
