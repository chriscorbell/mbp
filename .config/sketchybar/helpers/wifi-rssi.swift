import CoreWLAN
// Prints "<wifi-ifname> <rssi-dBm>", e.g. "en0 -50" (no sudo / Location needed).
// rssiValue() is 0 when Wi-Fi is off or not associated.
if let i = CWWiFiClient.shared().interface(), let name = i.interfaceName {
  print("\(name) \(i.rssiValue())")
} else {
  print("none 0")
}
