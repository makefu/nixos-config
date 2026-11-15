{ lib, ... }:
# 15 Nov 2026: python3Packages.posthog 7.71.0 is marked broken against mcp >= 2
# (nixpkgs sets meta.broken = versionAtLeast mcp.version "2") and its own suite fails one
# MCP case — test_prepare_tool_result_delivers_into_call_tool_result_models[bare]:
# 'CallToolResult' has no attribute 'structuredContent' (renamed in mcp 2). Import and
# runtime are unaffected; unblocks open-webui (direct dep) and chromadb (transitive).
# Drop this file when nixpkgs fixes posthog.
{
  nixpkgs.overlays = lib.mkAfter [
    (_final: prev: {
      python3Packages = prev.python3Packages.override {
        overrides = self: super: {
          posthog = super.posthog.overridePythonAttrs (old: {
            doCheck = false;
            meta = (old.meta or { }) // {
              broken = false;
            };
          });
        };
      };
    })
  ];
}
