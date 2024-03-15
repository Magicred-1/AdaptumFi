import Image from "next/image";
import { DynamicWidget } from '@dynamic-labs/sdk-react-core';

export default function Home() {
  return (
    <main>
          <DynamicWidget />
      <div>
        <h1>Dynamic Labs</h1>
        <p>
          Welcome to the Dynamic Labs demo. This is a simple example of a
          Next.js app that uses Dynamic Labs SDK.
        </p>
        <p>
          To get started, open the <code>app/page.tsx</code> file and start
          editing.
        </p>
      </div>
    </main>
  );
}
