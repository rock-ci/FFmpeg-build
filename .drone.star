FILEBUCKET_ENV = {
    "FILEBUCKET_USER": "drone.io",
    "FILEBUCKET_PASSWORD": {"from_secret": "FILEBUCKET_PASSWORD"},
    "FILEBUCKET_SERVER": {"from_secret": "FILEBUCKET_SERVER"},
}

def main(ctx):
    base_version = "7:4.3.4-0+deb11u1"
    drone_arch = "arm64"
    deb_arch = "arm64"
    docker_img = "ghcr.io/sigmaris/ffmpegbuilder:bullseye"
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "build_ffmpeg_%s" % drone_arch,
        "platform": {
            "os": "linux",
            "arch": drone_arch,
        },
        "workspace": {
            "base": "/drone",
            "path": "builder-src",
        },
        "trigger": {
            "ref": [
                "refs/heads/*",
                "refs/tags/*",
            ]
        },
        "clone": {
            "depth": 1
        },
        "steps": [
            # Prepare FFMPEG sourcecode
            {
                "name": "prepare",
                "image": docker_img,
                "environment": {
                    "BASE_VERSION": base_version,
                    "DEB_ARCH": deb_arch,
                },
                "commands": [
                    "cd ..",
                    "mkdir build",
                    "cd build",
                    "apt-get update",
                    "../builder-src/prepare.sh",
                ],
            },
            # Build FFMPEG
            {
                "name": "build",
                "image": docker_img,
                "environment": {
                    "BASE_VERSION": base_version,
                    "DEB_ARCH": deb_arch,
                },
                "commands": [
                    "cd /drone/build",
                    "wget https://github.com/sigmaris/linux/releases/download/6.0.3-rockpro64-ci/linux-libc-dev_6.0.3-g54e50e1b1-sigmaris_arm64.deb",
                    "apt-get -y install ./linux-libc-dev_6.0.3-g54e50e1b1-sigmaris_arm64.deb",
                    "../builder-src/build.sh",
                ],
                "depends_on": ["prepare"],
            },
            # Publish built artifacts to filebucket
            {
                "name": "publish_debs",
                "image": docker_img,
                "environment": FILEBUCKET_ENV,
                "commands": [
                    "cd /drone/build",
                    "/drone/builder-src/upload_artifacts.sh *.deb",
                ],
                "depends_on": ["build"],
            },
            # Upload artifacts to Github release for tag builds
            {
                "name": "release",
                "image": "ghcr.io/sigmaris/drone-github-release:latest",
                "settings": {
                    "api_key": {
                        "from_secret": "github_token",
                    },
                    "files": [
                        "/drone/build/*.deb",
                    ],
                    "checksum": [
                        "md5",
                        "sha1",
                        "sha256",
                    ]
                },
                "depends_on": ["build"],
                "when": {
                    "event": "tag",
                },
            },
        ]
    }
