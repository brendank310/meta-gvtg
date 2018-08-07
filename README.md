# meta-gvtg
An OE layer providing Intel's gvt-g (initially Xen only)

The focus of this layer is to standardize the building of the components of Intel's GVTg technology for mediated device passthrough of Intel Integrated Graphics (IGFX).

To use the layer, add the following to your local.conf:

```
PACKAGECONFIG_append_pn-qemu-target = " gvtg"
PREFERRED_VERSION_xen = "4.10+git"
PREFERRED_VERSION_qemu-target = "git"
PREFERRED_PROVIDER_virtual/kernel = "linux-xengt"
```

meta-virtualization is required. Instructions for using GVTg with a build produced by this layer will be forthcoming.

The ultimate goal for this layer is to be a basis to fixup the local access to guest framebuffers as was in previous versions of XenGT (indirect mode), and bring feature parity to the local dma-buf implementation available for KVMGT. This would be especially useful for projects like https://github.com/openxt.
