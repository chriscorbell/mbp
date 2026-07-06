// @ts-check

/**
 * @typedef {import('/Applications/Finicky.app/Contents/Resources/finicky.d.ts').FinickyConfig} FinickyConfig
 */

const edgeOpeners = new Set([
  "com.microsoft.Outlook",
  "com.microsoft.teams",
  "com.microsoft.teams2",
]);

const edgeOpenerNames = new Set([
  "Microsoft Outlook",
  "Outlook",
  "Microsoft Teams",
]);

const opensInEdge = (opener) => {
  if (!opener) return false;

  if (edgeOpeners.has(opener.bundleId)) return true;
  if (edgeOpenerNames.has(opener.name)) return true;

  return [
    "/Applications/Microsoft Outlook.app",
    "/Applications/Microsoft Teams.app",
  ].some((path) => opener.path === path || opener.path.startsWith(`${path}/`));
};

/**
 * @type {FinickyConfig}
 */
export default {
  defaultBrowser: "Zen",
  handlers: [
    {
      match: (_url, { opener }) => opensInEdge(opener),
      browser: "Microsoft Edge",
    },
  ],
};
