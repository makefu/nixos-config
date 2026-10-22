{ pkgs, ... }:
# STL thumbnails in Dolphin (and other freedesktop-thumbnailed file managers).
# KF6 kio's FilePreviewJob scans XDG_DATA_DIRS for *.thumbnailer files; f3d
# ships share/thumbnailers/f3d-plugin-native.thumbnailer covering model/stl
# (plus gltf/obj/ply/vtk/... for free). Rendering is headless (EGL/OSMesa
# fallback) so it works without a display server.
{
  users.users.makefu.packages = [ pkgs.f3d ];
}
