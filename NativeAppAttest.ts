import type { TurboModule } from "react-native/Libraries/TurboModule/RCTExport";
import { TurboModuleRegistry } from "react-native";

type Attestation = string;

export interface AppAttestSpec extends TurboModule {
  isSupported(): Promise<boolean>;
  generateKey(): Promise<string>;
  attestKey(keyId: string, clientDataHash: string): Promise<Attestation>;
  generateAssertion(
    keyId: string,
    clientDataHash: string
  ): Promise<Attestation>;
}

export default TurboModuleRegistry.get<AppAttestSpec>(
  "RTNAppAttest"
) as AppAttestSpec | null;
