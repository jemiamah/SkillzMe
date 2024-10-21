import {
  Client,
  Provider,
  ProviderRegistry,
  Result,
} from "@blockstack/clarity";

describe("skill verification contract test suite", () => {
  let client: Client;
  let provider: Provider;
  
  beforeEach(async () => {
    provider = await ProviderRegistry.createProvider();
    client = new Client("SP3GWX3NE58KXHESRYE4DYQ1S31PQJTCRXB3PE9SB.skill-verification", "skill-verification", provider);
  });
  
  afterEach(async () => {
    await provider.close();
  });
  
  it("should create a new skill", async () => {
    const tx = client.createTransaction({
      method: { name: "create-skill", args: ["Programming", "Basic programming skills", "3"] }
    });
    const receipt = await tx.submit();
    expect(receipt.success).toBe(true);
  });
  
  it("should allow requesting verification", async () => {
    const tx = client.createTransaction({
      method: { name: "request-verification", args: ["1"] }
    });
    const receipt = await tx.submit();
    expect(receipt.success).toBe(true);
  });
  
  it("should handle voting process", async () => {
    const tx = client.createTransaction({
      method: { name: "vote-on-verification", args: ["1", "SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7", "true"] }
    });
    const receipt = await tx.submit();
    expect(receipt.success).toBe(true);
  });
});

