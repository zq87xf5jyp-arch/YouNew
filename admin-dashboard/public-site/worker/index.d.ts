interface StaticAssetsBinding {
  fetch(request: Request): Promise<Response>;
}

declare const worker: {
  fetch(
    request: Request,
    env: { ASSETS: StaticAssetsBinding }
  ): Promise<Response>;
};

export default worker;
