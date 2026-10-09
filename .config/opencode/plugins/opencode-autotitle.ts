import mod from "file:///Users/dm/.config/opencode/plugins/opencode-autotitle.js"
const fn = (typeof mod === "function") ? mod : (typeof (mod as any)?.default === "function" ? (mod as any).default : (typeof mod === 'object' ? (mod as any).AutoTitle : null))
if (!fn) throw new Error("autotitle: no plugin fn found")
export default fn
