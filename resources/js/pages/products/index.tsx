import {
    Table,
    TableBody,
    TableCaption,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table';
import AppLayout from '@/layouts/app-layout';
import { type BreadcrumbItem } from '@/types';
import { Head } from '@inertiajs/react';

interface Product {
    id: number;
    name: string;
    description: string;
    stock: number;
    price: number;
}

const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Products',
        href: '/products',
    },
];

export default function Index({ products }: { products: Product[] }) {
    return (
        <AppLayout breadcrumbs={breadcrumbs}>
            <Head title="Products | list" />
            {products.length > 0 && (
                <Table>
                    <TableCaption>A list of your recent invoices.</TableCaption>
                    <TableHeader>
                        <TableRow>
                            <TableHead className="w-[100px]">ID</TableHead>
                            <TableHead>Name</TableHead>
                            <TableHead>Description</TableHead>
                            <TableHead>Stock</TableHead>
                            <TableHead>Price</TableHead>
                            <TableHead className="text-right">
                                Actions
                            </TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {products.map((product) => (
                            <TableRow key={product.id}>
                                <TableCell className="font-medium">
                                    {product.id}
                                </TableCell>
                                <TableCell>{product.name}</TableCell>
                                <TableCell>{product.description}</TableCell>
                                <TableCell>{product.stock}</TableCell>
                                <TableCell>{product.price}</TableCell>
                                <TableCell className="text-right"></TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            )}
        </AppLayout>
    );
}
