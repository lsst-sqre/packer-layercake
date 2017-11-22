packer-layercake
=================

__Notice: This package is not presently intended to be of value to any party
external to the LSST DM/SQRE group.__

Packer recipes for building VM and container images with a complete LSST DM
"stack" install based on the
[`newinstall`](https://github.com/lsst/lsst/blob/master/scripts/newinstall.sh)
bootstrap process with the individual packages built from `eups distrib`.  The
intent is to closely replicate the process a down-stream consumer of LSST DM
software products would use.

OpenStack/Nebula Images
---

__At present, Nebula images are based on "published" Centos 6/7 images provided
for end users.  In the future, this will be replaced with a packer generated
qemu image that is uploaded to Nebula.__

### Step 0

Source the `LSST-openrc.sh` step script so that the env vars necessary for
`packer` to communicate with openstack/nebula are present.

### Step 1

Build base images suitable for usage by vagrant with jhoblitt's fork of
`bento`.

    git clone git@github.com:jhoblitt/bento.git -b builder/aws
    cd bento
    git checkout 2961070 # rebased on upstream bento @ 2016-02-05
    make
    ./packer/packer build --only=openstack ./centos-6.7-x86_64.json
    ./packer/packer build --only=openstack ./centos-7.2-x86_64.json

_The `bento` images only need to be [re-]recreated upon new features or major
base OS changes.  Such as a new minor release._

### Step 2

Build `newinstall` base images that have all operating system prerequisites
installed along with the basic `newinstall.sh` prepared build env.  Here the
`CENTOSX_IMAGE` env vars should be set to the UUID ID of the current `bento`
base images.

    export CENTOS6_IMAGE=<...>
    export CENTOS7_IMAGE=<...>
    ./build-openstack newinstall

_The `newinstall` images should be created when ever changes (directly or
indirectly) occur to `newinstall.sh` or when new `bento` images have been
generated._

### Step 3

Build the end-user consumable `stack` images with pre-build eups products.  The
`CENTOSX_IMAGE` env bars need to be updated to the UUID of the `newinstall`
generated images.

    export TAG=w_2016_05
    export PRODUCTS=lsst_distrib
    export CENTOS6_IMAGE=<...>
    export CENTOS7_IMAGE=<...>
    ./build-openstack build

### Step 4

Run the stack demo on an instance created from each new candidate image.

See: http://sqr-002.lsst.io/en/latest/#running-the-stack-demo

This may be conveniently accomplished by cloning the
https://github.com/lsst-sqre/vagrant-nebula.git repo and updating the UUIDs for
the `el6` and `el7` boxes.

### Step 5

Update these repos:

* https://github.com/lsst-sqre/sqr-002
* https://github.com/lsst-sqre/vagrant-nebula

Then announce it to the [LSST DM] world via `community.lsst.org` and on the
hipchat `square` and `nebula` channels.


Docker containers
---

### Step 0

Log into a dockerhub account that is a member of the `lsstsqre` organization.

    docker login
    ....

### Step 1

Build the intermediate `newinstall` images.

    ./build-docker newinstall

_The `newinstall` images should be created when ever changes (directly or
indirectly) occur to `newinstall.sh` or when new `bento` images have been
generated._

### Step 2

Build the `stack` consumable images.

    export TAG=w_2016_05
    export PRODUCTS=lsst_distrib
    ./build-docker build

### Step 3

Push final container images

    ./build-docker push

### Step 4

Run the stack demo on a container created from each new candidate image.

See: http://sqr-002.lsst.io/en/latest/#running-the-stack-demo

### Step 5

Update these repos:

* https://github.com/lsst-sqre/sqr-002

Then announce it to the [LSST DM] world via `community.lsst.org` and on the
hipchat `square` channel.


Work-in-progress QEMU->Nebula upload instructions
=================================================

    openstack image create --container-format bare --disk-format qcow2 --min-disk 0 --min-ram 0 --file packer-centos-7.1-x86_64-20151120221107-qemu/centos-7.1-x86_64-20151120221107 packer-centos-7.1-x86_64-20151120221107-qemu

    openstack image create --container-format bare --disk-format qcow2 --min-disk 0 --min-ram 0 --file packer-centos-6.7-x86_64-20151120221334-qemu/centos-6.7-x86_64-20151120221334 packer-centos-6.7-x86_64-20151120221334-qemu


Work-in-progress AWS instructions
=================================

Building QEMU/KVM images with packer
---

In theory, these images can both be uploaded to aws and openstack/nebula.

from bento repos on the `builder/aws` branch

(source AMI credentials in env)

    ./bin/packer build --only=qemu --var headless=true centos-7.1-x86_64.json
    ./bin/packer build --only=qemu --var headless=true centos-6.7-x86_64.json

Upload a QEMU/KVM image to EC2 as the image of a shutdown instance
---

After the upload/import completes, the instance can be converted to an ami.

See: https://docs.aws.amazon.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-ImportInstance.html

Note that the destination instance type is restricted.  See:
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/VMImportTroubleshooting.html#LinuxNotSupported

(build kvm images with packer/bento)

```
wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
unzip ec2-api-tools.zip
export EC2_HOME=`pwd`/ec2-api-tools-1.7.5.1
export JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk/jre"

# are these env vars used at all?
export AWS_ACCESS_KEY=AWS_ACCESS_KEY_ID
export AWS_SECRET_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_ACCESS_KEY=$AWS_ACCESS_KEY_ID

# aws does not accept qcow2 format images; convert -> raw
qemu-img convert -f qcow2 -O raw packer-centos-7.1-x86_64-qemu/centos-7.1-x86_64 packer-centos-7.1-x86_64-qemu/centos-7.1-x86_64.raw

export DESCRIPTION=centos-7.1-x86_64-20151120221107
# we are using ec2-api-tools as the aws cli does not have a single command to
# upload to s3 and then import as an instance.
# aws ec2 import-image will import from an s3 object
./ec2-api-tools-1.7.5.1/bin/ec2-import-instance  --owner-akid $AWS_ACCESS_KEY_ID --owner-sak $AWS_SECRET_ACCESS_KEY --format raw --instance-type c3.large --architecture x86_64 --bucket bucketmantakemetoouterspace --platform Linux --description $DESCRIPTION packer-centos-7.1-x86_64-20151120221107-qemu/centos-7.1-x86_64-20151120221107.raw

# note conversion-task-id
export TASK_ID=import-i-fgc8mi82

# wait until "Status" is "completed", then find InstanceId
aws ec2 describe-conversion-tasks --conversion-task-ids $TASK_ID

export INSTANCE_ID=i-b8039408

# note that
# the instance is not cleaned up...
# nor is the volume
# nor is s3 bucket

# convert shutdown instance to ami
# XXX need to set storage type to gp2
aws ec2 create-image --instance-id $INSTANCE_ID --name "$DESCRIPTION" --description "$DESCRIPTION" --block-device-mappings '[{"DeviceName": "/dev/sda1","Ebs":{"VolumeType": "gp2"}}]'

# note ImageId

export IMAGE_ID=ami-6c0e4906

# wait for "State" to become "available"
aws ec2 describe-images --image-ids $IMAGE_ID

# cleanup
aws ec2 describe-instances --instance-ids $INSTANCE_ID
# find VolumeId
export VOLUME_ID="vol-5aa663a7"

aws ec2 terminate-instances --instance-ids $INSTANCE_ID

aws ec2 delete-volume --volume-id $VOLUME_ID
# snapshots can not be cleaned while they are in use by the ami; if the ami is deregistered, they can then be removed
# aws ec2 describe-snapshots --filters=Name=volume-id,Values=vol-481fedb5

# purge s3 objects -- this is really slow
./ec2-api-tools-1.7.5.1/bin/ec2-delete-disk-image  --owner-akid $AWS_ACCESS_KEY_ID --owner-sak $AWS_SECRET_ACCESS_KEY --task $TASK_ID


# making an ami public
# see: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/sharingamis-intro.html

# this is not needed for the base images; packer can set the permissions on the
final "product"

aws ec2 modify-image-attribute --image-id $IMAGE_ID --launch-permission "{\"Add\":[{\"Group\":\"all\"}]}"

aws ec2 describe-image-attribute --image-id $IMAGE_ID --attribute launchPermission
```


Upload a QEMU/KVM image directly as a volume
---

See: https://docs.aws.amazon.com/AWSEC2/latest/CommandLineReference/ApiReference-cmd-ImportVolume.html

    qemu-img convert -f qcow2 -O raw packer-centos-6.7-x86_64-qemu/centos-6.7-x86_64 packer-centos-6.7-x86_64-qemu/centos-6.7-x86_64.raw

    ./ec2-api-tools-1.7.5.1/bin/ec2-import-volume packer-centos-6.7-x86_64-qemu/centos-6.7-x8 bucketmantakemetoouterspace --owner-akid $AWS_ACCESS_KEY_ID --owner-sak $AWS_SECRET_ACCESS_KEY --region us-east-1

    ./ec2-api-tools-1.7.5.1/bin/ec2-describe-conversion-tasks

    # find VolumeId in output. Eg.
    # VolumeId vol-5d2785be

**A volume has to be attached to an instance before it can be converted to an AMI (why?????)**
